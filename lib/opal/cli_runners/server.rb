require 'opal/cli_runners'

module Opal
  class CliServerRunner
    def initialize(output, port)
      @output ||= output || $stdout
    end
    attr_reader :output

    def run(source)
      require 'rack'
      require 'webrick'
      require 'logger'

      @thread = Thread.new do
        @server = Rack::Server.start(
          :app       => app(source),
          :Port      => port,
          :AccessLog => [],
          :Logger    => Logger.new(output)
        )
      end
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
