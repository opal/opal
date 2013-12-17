require 'rack/file'
require 'rack/urlmap'
require 'rack/builder'
require 'rack/directory'
require 'rack/showexceptions'
require 'opal/source_map'
require 'opal/sprockets/environment'
require 'erb'

module Opal

  class SourceMapServer
    def initialize sprockets
      @sprockets = sprockets
    end

    attr_reader :sprockets

    attr_writer :prefix

    def prefix
      @prefix ||= '/__opal_source_maps__'
    end

    def inspect
      "#<#{self.class}:#{object_id}>"
    end

    def call(env)
      path_info = env['PATH_INFO']

      if path_info =~ /\.js\.map$/
        path   = env['PATH_INFO'].gsub(/^\/|\.js\.map$/, '')
        asset  = sprockets[path]
        return [404, {}, []] if asset.nil?

        return [200, {"Content-Type" => "text/json"}, [$OPAL_SOURCE_MAPS[asset.pathname].to_s]]
      else
        return [200, {"Content-Type" => "text/text"}, [File.read(sprockets.resolve(path_info))]]
      end
    end
  end

  class Server

    attr_accessor :debug, :index_path, :main, :public_dir, :sprockets

    def initialize debug_or_options = {}
      unless Hash === debug_or_options
        warn "passing a boolean to control debug is deprecated.\n"+
             "Please pass an Hash instead: Server.new(debug: true)"
        options = {:debug => debug_or_options}
      else
        options = debug_or_options
      end

      @public_dir = '.'
      @sprockets  = Environment.new
      @debug      = options.fetch(:debug, true)

      yield self if block_given?
      create_app
    end

    def source_map_enabled
      Opal::Processor.source_map_enabled
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
        map(server.source_maps.prefix) { run server.source_maps } if server.source_map_enabled
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
        if @index_path
          raise "index does not exist: #{@index_path}" unless File.exist?(@index_path)
          Tilt.new(@index_path).render(self)
        elsif index = search_html_path
          Tilt.new(index).render(self)
        else
          ::ERB.new(SOURCE).result binding
        end
      end

      def search_html_path
        %w[index.html index.html.haml index.html.erb].find do |path|
          File.exist? path
        end
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
