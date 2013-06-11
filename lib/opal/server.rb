require 'erb'
require 'rack'
require 'rack/showexceptions'
require 'opal/sprockets_source_map_header'
require 'opal/source_map'

module Opal
  class Environment < ::Sprockets::Environment
    def initialize *args
      super
      Opal.paths.each { |p| append_path p }
    end

    def use_gem gem_name
      append_path File.join(Gem::Specification.find_by_name(gem_name).gem_dir, 'lib')
    end
  end

  class SourceMapServer
    def initialize sprockets
      @sprockets = sprockets
    end

    attr_reader :sprockets

    attr_writer :prefix

    def prefix
      @prefix ||= '/__opal_source_maps__'
    end

    def call(env)
      path   = env['PATH_INFO'].gsub(/^\/|\.js\.map$/, '')
      asset  = sprockets[path]
      source = asset.to_s
      map    = Opal::SourceMap.new(source, asset.pathname.to_s)

      return [200, {"Content-Type" => "text/json"}, [map.to_s]]
    end
  end

  class Server

    attr_accessor :debug, :index_path, :main, :public_dir, :sprockets

    def initialize debug = true
      @public_dir = '.'
      @sprockets  = Environment.new
      @debug      = debug

      yield self if block_given?
      create_app
    end

    def append_path path
      @sprockets.append_path path
    end

    def use_gem gem_name
      @sprockets.use_gem gem_name
    end

    def create_app
      server, sprockets = self, @sprockets

      @app = Rack::Builder.app do
        use Rack::ShowExceptions
        map('/assets') { run sprockets }
        map(server.source_maps.prefix) { run server.source_maps }
        use Index, server
        run Rack::Directory.new(server.public_dir)
      end
    end

    def source_maps
      @source_maps ||= SourceMapServer.new(@sprockets)
    end

    def call(env)
      @app.call env
    end

    class Index

      def initialize(app, server)
        @app = app
        @server = server
        @index_path = server.index_path
      end

      def call(env)
        if %w[/ /index.html].include? env['PATH_INFO']
          [200, { 'Content-Type' => 'text/html' }, [html]]
        else
          @app.call env
        end
      end

      # Returns the html content for the root path. Supports ERB
      def html
        source = if @index_path
          raise "index does not exist: #{@index_path}" unless File.exist?(@index_path)
          File.read @index_path
        elsif File.exist? 'index.html'
          File.read 'index.html'
        elsif File.exist? 'index.html.erb'
          File.read 'index.html.erb'
        else
          SOURCE
        end

        ::ERB.new(source).result binding
      end

      def javascript_include_tag source
        if @server.debug
          assets = @server.sprockets[source].to_a

          raise "Cannot find asset: #{source}" if assets.empty?

          scripts = assets.map do |a|
            %Q{<script src="/assets/#{ a.logical_path }?body=1"></script>}
          end

          scripts.join "\n"
        else
          "<script src=\"/assets/#{source}.js\"></script>"
        end
      end

      SOURCE = <<-HTML
  <!DOCTYPE html>
  <html>
  <head>
    <title>Opal Server</title>
  </head>
  <body>
    <%= javascript_include_tag @server.main %>
  </body>
  </html>
      HTML
    end
  end
end
