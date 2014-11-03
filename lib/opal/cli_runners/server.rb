require 'opal/cli_runners'

module Opal
  module CliRunners
    class Server
      def initialize(output, port)
        @output ||= output || $stdout
        @port = port
      end
      attr_reader :output, :port, :server

      def run(source, argv)
        unless argv.empty?
          raise ArgumentError, 'Program arguments are not supported on the PhantomJS runner'
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
                <script>
                //<![CDATA[
                #{source}
                //]]>
                </script>
              </head>
            </html>
            HTML
            [200, {}, [body]]
          else
            [404, {}, [body]]
          end
        end
      end
    end
  end
end
