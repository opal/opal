# frozen_string_literal: true

require 'opal/deprecations'

# Opal::SimpleServer is a very basic Rack server for Opal assets, it relies on
# Opal::Builder and Ruby corelib/stdlib. It's meant to be used just for local
# development.
#
# For a more complete implementation see opal-sprockets (Rubygems) or
# opal-webpack (NPM).
#
# @example (CLI)
#   rackup -ropal -ropal/simple_server -b 'Opal.append_path("app"); run Opal::SimpleServer.new'
#   ... or use the Server runner ...
#   opal -Rserver app.rb
class Opal::SimpleServer
  require 'set'
  require 'erb'

  NotFound = Class.new(StandardError)

  def initialize(options = {})
    @prefix = options.fetch(:prefix, 'assets').delete_prefix('/')
    @main = options.fetch(:main, 'application')
    @builder = options.fetch(:builder, nil)
    @transformations = []
    @index_path = nil
    @builders = {}
    yield self if block_given?
  end

  attr_accessor :main, :index_path

  def append_path(path)
    @transformations << [:append_paths, path]
  end

  def call(env)
    case env['PATH_INFO']
    when %r{\A/#{@prefix}/(.*?)\.m?js(/.*)?\z}
      path, rest = Regexp.last_match(1), Regexp.last_match(2)&.delete_prefix('/').to_s
      call_js(path, rest)
    else call_index
    end
  rescue NotFound => error
    [404, {}, [error.to_s]]
  end

  def call_js(path, rest)
    asset = fetch_asset(path, rest)
    [
      200,
      { 'content-type' => 'application/javascript' },
      @directory ? [asset[:data]] : [asset[:data], "\n", asset[:map].to_data_uri_comment],
    ]
  end

  def builder(path)
    case @builder
    when Opal::Builder
      builder = @builder
    when Proc
      if @builder.arity == 0
        builder = @builder.call
      else
        builder = @builder.call(path)
      end
    else
      builder = Opal::Builder.new
      builder = apply_builder_transformations(builder)
      builder.build(path.gsub(/(\.(?:rb|m?js|opal))*\z/, ''))
    end

    @esm = builder.compiler_options[:esm]
    @directory = builder.compiler_options[:directory]

    builder
  end

  # Only cache one builder at a time
  def cached_builder(path, uncache: false)
    @builders = {} if uncache || @builders.keys != [path]
    @builders[path] ||= builder(path)
  end

  def apply_builder_transformations(builder)
    @transformations.each do |type, *args|
      case type
      when :append_paths
        builder.append_paths(*args)
      end
    end
    builder
  end

  def fetch_asset(path, rest)
    builder = cached_builder(path)
    if @directory
      { data: builder.compile_to_directory(single_file: rest) }
    else
      {
        data: builder.to_s,
        map: builder.source_map
      }
    end
  end

  def javascript_include_tag(path)
    # Uncache previous builders and cache a new one
    cached_builder(path, uncache: true)

    path += ".#{js_ext}/index" if @directory

    if @esm
      %{<script src="/#{@prefix}/#{path}.#{js_ext}" type="module"></script>}
    else
      %{<script src="/#{@prefix}/#{path}.#{js_ext}"></script>}
    end
  end

  def call_index
    if @index_path
      contents = File.read(@index_path)
      html = ERB.new(contents).result binding
    else
      html = <<-HTML
      <!doctype html>
      <html>
        <head>
          <meta charset="utf-8">
        </head>
        <body>
          #{javascript_include_tag(main)}
        </body>
      </html>
      HTML
    end
    [200, { 'content-type' => 'text/html', 'cache-control' => 'no-cache' }, [html]]
  end

  def js_ext
    @esm ? 'mjs' : 'js'
  end
end
