# frozen_string_literal: true

module Opal
  module CliRunners
    class Server
      def initialize(options)
        @output = options.fetch(:output, $stdout)

        @port = options.fetch(:port, ENV['OPAL_CLI_RUNNERS_SERVER_PORT'] || 3000).to_i

        @static_folder = options[:static_folder] || ENV['OPAL_CLI_RUNNERS_SERVER_STATIC_FOLDER']
        @static_folder = @static_folder == true ? 'public' : @static_folder
        @static_folder = File.expand_path(@static_folder) if @static_folder
      end
      attr_reader :output, :port, :server, :static_folder

      def run(source, argv)
        unless argv.empty?
          raise ArgumentError, 'Program arguments are not supported on the Server runner'
        end

        require 'rack'
        require 'webrick'
        require 'logger'

        app = build_app(source)

        @server = Rack::Server.start(
          app:       app,
          Port:      port,
          AccessLog: [],
          Logger:    Logger.new(output),
        )
      end

      def exit_status
        nil
      end

      def build_app(source)
        app = App.new(source)

        if static_folder
          not_found = [404, {}, []]
          app = Rack::Cascade.new(
            [
              Rack::Static.new(->(_) { not_found }, urls: [''], root: static_folder),
              app
            ],
          )
        end

        app
      end

      class App
        def initialize(source)
          @source = source
        end

        BODY = <<-HTML
          <!doctype html>
          <html>
            <head>
              <meta charset="utf-8"/>
              <script src="/cli_runner.js"></script>
            </head>
          </html>
        HTML

        def call(env)
          case env['PATH_INFO']
          when '/'
            [200, { 'Content-Type' => 'text/html' }, [BODY]]
          when '/cli_runner.js'
            [200, { 'Content-Type' => 'text/javascript' }, [@source]]
          else
            [404, {}, ['not found']]
          end
        end
      end
    end
  end
end
