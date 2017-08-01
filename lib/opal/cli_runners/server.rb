# frozen_string_literal: true

module Opal
  module CliRunners
    class Server
      def initialize(options)
        @output = options.fetch(:output, $stdout)
        @port = options.fetch(:port, 3000).to_int
      end
      attr_reader :output, :port, :server

      def run(source, argv)
        unless argv.empty?
          raise ArgumentError, 'Program arguments are not supported on the Server runner'
        end

        require 'rack'
        require 'webrick'
        require 'logger'

        @server = Rack::Server.start(
          :app       => app(source),
          :Port      => port,
          :AccessLog => [],
          :Logger    => Logger.new(output)
        )
      end

      def exit_status
        nil
      end

      def app(source)
        lambda do |env|
          case env['PATH_INFO']
          when '/'
            body = <<-HTML
            <!doctype html>
            <html>
              <head>
                <meta charset="utf-8"/>
                <script src="/cli_runner.js"></script>
              </head>
            </html>
            HTML
            [200, {}, [body]]
          when '/cli_runner.js'
            [200, {'Content-Type' => 'text/javascript'}, [source]]
          else
            [404, {}, [body]]
          end
        end
      end
    end
  end
end
