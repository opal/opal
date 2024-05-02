# frozen_string_literal: true

require 'opal/deprecations'
require 'opal/rack_handler'

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
    builder = options.fetch(:builder, nil)
    @prefix = options.fetch(:prefix, 'assets').delete_prefix('/')
    @main = options.fetch(:main, 'application')
    @app_dir = options.fetch(:app_dir, 'app')
    @index_path = nil

    yield self if block_given?

    @production = ENV['RACK_ENV'] == 'production'
    @start_time = Time.now.to_i

    app_call = proc do |env|
      call_index
    rescue NotFound => error
      [404, {}, [error.to_s]]
    end

    yield self if block_given?
    @handler = Opal::RackHandler.new(app_call, { prefix: @prefix, main: @main, builder: builder,
                                                 hot_updates: hot_updates == false ? false : true,
                                                 hot_javascript: hot_javascript,
                                                 hot_ruby: hot_ruby })
  end

  attr_accessor :main, :index_path, :hot_updates, :hot_ruby, :hot_javascript

  attr_reader :app_dir

  def app_dir=(d)
    @app_dir = d
    Opal.append_path @app_dir
  end

  def production?
    @production
  end

  def append_path(path)
    @transformations << [:append_paths, path]
  end

  def call(env)
    @handler.call(env)
  end

  def javascript_include_tag(path)
    # Uncache previous builders and cache a new one

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
