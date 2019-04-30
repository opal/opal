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
class Opal::SimpleServer
  require 'set'
  require 'erb'

  NotFound = Class.new(StandardError)

  def initialize(options = {})
    @prefix = options.fetch(:prefix, 'assets')
    @main = options.fetch(:main, 'application')
    @index_path = nil
    yield self if block_given?
    freeze
  end

  attr_accessor :main, :index_path

  # @deprecated
  # It's here for compatibility with Opal::Sprockets::Server
  def append_path(path)
    Opal.deprecation "`#{self.class}#append_path` is deprecated, please use `Opal.append_path(path)` instead (called from: #{caller(1, 1).first})"
    Opal.append_path path
  end

  def call(env)
    case env['PATH_INFO']
    when %r{\A/#{@prefix}/(.*)\.js\z}
      path, _cache_invalidator = Regexp.last_match(1).split('?', 2)
      call_js(path)
    else call_index
    end
  rescue NotFound => error
    [404, {}, [error.to_s]]
  end

  def call_js(path)
    asset = fetch_asset(path)
    [
      200,
      { 'Content-Type' => 'application/javascript' },
      [asset[:data], "\n", asset[:map].to_data_uri_comment],
    ]
  end

  def fetch_asset(path)
    builder = Opal::Builder.new
    builder.build(path.gsub(/(\.(?:rb|js|opal))*\z/, ''))
    {
      data: builder.to_s,
      map: builder.source_map,
      source: builder.source_for(path),
    }
  end

  def javascript_include_tag(path)
    %{<script src="/#{@prefix}/#{path}.js#{cache_invalidator}"></script>}
  end

  def cache_invalidator
    "?#{Time.now.to_i}"
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
          <meta charset="utf8">
          #{javascript_include_tag(main)}
        </head>
        <body></body>
      </html>
      HTML
    end
    [200, { 'Content-Type' => 'text/html' }, [html]]
  end
end
