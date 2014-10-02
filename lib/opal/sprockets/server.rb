require 'rack/file'
require 'rack/static'
require 'rack/urlmap'
require 'rack/builder'
require 'rack/deflater'
require 'rack/directory'
require 'rack/showexceptions'
require 'opal/source_map'
require 'opal/sprockets/environment'
require 'erb'

module Opal

  class SourceMapServer
    def initialize sprockets, prefix = '/'
      @sprockets = sprockets
      @prefix = prefix
    end

    attr_reader :sprockets, :prefix

    def inspect
      "#<#{self.class}:#{object_id}>"
    end

    def call(env)
      prefix_regex = %r{^(?:#{prefix}/|/)}
      path_info = env['PATH_INFO'].to_s.sub(prefix_regex, '')

      case path_info
      when %r{^(.*)\.map$}
        path = $1
        asset  = sprockets[path]
        return not_found(path) if asset.nil?

        # "logical_name" of a BundledAsset keeps the .js extension
        source = register[asset.logical_path.sub(/\.js$/, '')]
        return not_found(asset) if source.nil?

        return [200, {"Content-Type" => "text/json"}, [source.to_s]]
      when %r{^(.*)\.rb$}
        source = File.read(sprockets.resolve(path_info))
        return not_found(path_info) if source.nil?
        return [200, {"Content-Type" => "text/ruby"}, [source]]
      else
        not_found(path_info)
      end
    end

    def not_found(*messages)
      not_found = [404, {}, [{not_found: messages, keys: register.keys}.inspect]]
    end

    def register
      Opal::Processor.source_map_register
    end
  end

  class Server

    attr_accessor :debug, :use_index, :index_path, :main, :public_root,
                  :public_urls, :sprockets, :prefix

    def initialize debug_or_options = {}
      unless Hash === debug_or_options
        warn "passing a boolean to control debug is deprecated.\n"+
             "Please pass an Hash instead: Server.new(debug: true)"
        options = {:debug => debug_or_options}
      else
        options = debug_or_options
      end

      @use_index   = true
      @public_root = nil
      @public_urls = ['/']
      @sprockets   = Environment.new
      @debug       = options.fetch(:debug, true)
      @prefix      = options.fetch(:prefix, '/assets')

      yield self if block_given?
      create_app
    end

    def public_dir=(dir)
      @public_root = dir
      @public_urls = ["/"]
    end

    def source_map=(enabled)
      Opal::Processor.source_map_enabled = enabled
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
      server, sprockets, prefix = self, @sprockets, self.prefix
      sprockets.logger.level = Logger::DEBUG
      apps = []
      apps << Rack::Builder.app do
        not_found = lambda { |env| [404, {}, []] }
        use Rack::Deflater
        use Rack::ShowExceptions
        use Index, server if server.use_index
        run Rack::Static.new(not_found, :root => server.public_root, :urls => server.public_urls)
      end
      apps << SourceMapServer.new(sprockets, prefix) if server.source_map_enabled
      apps << sprockets
      @app = Rack::Cascade.new(apps)
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
        else
          ::ERB.new(SOURCE).result binding
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
