require 'opal/cli_runners/browser_runner'
require 'rack'
require 'stringio'

module Opal
  module CliRunners
    class PuppeteerRuby < BrowserRunner
      class Exit < StandardError; end

      def run
        begin
          require 'puppeteer-ruby'
        rescue LoadError
          raise "Please 'gem install puppeteer-ruby' for #{self.describe.class} runner to work"
        end

        mktmpdir do |dir|
          prepare_files_in(dir)

          maybe_run_server(dir) do            
            Puppeteer.launch(product: product, headless: true) do |browser|
              page = browser.new_page

              page.default_navigation_timeout = 3600 * 24 * 356

              page.on PageEmittedEvents::Console do |msg|
                outdev = case msg.log_type
                         when "log"   then $stdout
                         when "error" then $stderr
                         else              $stdout
                         end

                outdev << msg.text
              end

              page.on PageEmittedEvents::PageError do |err|
                $stderr.puts err.message
                exit 1
              end

              page.on PageEmittedEvents::Dialog do |dialog|
                if dialog.type == 'prompt'
                  message = gets&.chomp
                  if message
                    dialog.accept(message)
                  else
                    dialog.dismiss
                  end
                end
              end

              page.on PageEmittedEvents::Load do
                exit(page.evaluate("() => window.OPAL_EXIT_CODE") || 0)
              end

              page.goto url dir

              sleep(3600 * 24 * 365)
            rescue Exit => e
              e.message.to_i
            ensure
              browser.close
            end
          end
        end
      end

      private

      def exit(code)
        Thread.main.raise Exit, code.to_s
      end
    end

    class Chromium < PuppeteerRuby
      private

      def product
        'chrome'
      end

      def url(dir)
        "file://#{dir}/index.html"
      end

      def maybe_run_server(_)
        yield
      end
    end

    class Firefox < PuppeteerRuby
      private

      def product
        'firefox'
      end

      def url(_)
        "http://127.0.0.1:#{@port}/index.html"
      end

      # Somehow, Firefox requires a server. It's not possible to use CDP to automate
      # file:// URLs.
      def maybe_run_server(dir)
        not_found = [404, {}, []]
        app = Rack::Static.new(->(_) { not_found }, urls: [''], root: dir)

        @port = rand(20000) + 30000

        thread = Thread.new do
          Rack::Server.start(
            app:       app,
            Port:      @port,
            Silent:    true
          )
        end

        yield.tap { thread.exit }
      end
    end
  end
end
