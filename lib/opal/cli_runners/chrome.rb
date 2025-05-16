# frozen_string_literal: true

require 'shellwords'
require 'socket'
require 'timeout'
require 'tmpdir'
require 'rbconfig'
require 'opal/os'

module Opal
  module CliRunners
    class Chrome
      SCRIPT_PATH = File.expand_path('cdp_interface.rb', __dir__).freeze

      DEFAULT_CDP_HOST = 'localhost'
      DEFAULT_CDP_PORT = 9222

      def self.call(data)
        runner = new(data)
        runner.run
      end

      def initialize(data)
        argv = data[:argv]
        if argv && argv.any?
          warn "warning: ARGV is not supported by the Chrome runner #{argv.inspect}"
        end

        options  = data[:options]
        @output  = options.fetch(:output, $stdout)
        @builder = data[:builder].call
      end

      attr_reader :output, :exit_status, :builder

      def run
        mktmpdir do |dir|
          with_chrome_server do
            prepare_files_in(dir)

            env = {
              'OPAL_CDP_HOST' => chrome_host,
              'OPAL_CDP_PORT' => chrome_port.to_s,
              'NODE_PATH' => File.join(__dir__, 'node_modules'),
              'OPAL_CDP_EXT' => builder.output_extension
            }

            cmd = [
              RbConfig.ruby,
              "#{__dir__}/../../../exe/opal",
              '--no-exit',
              '-I', __dir__,
              '-r', 'source-map-support-node',
              SCRIPT_PATH,
              dir
            ]

            Kernel.exec(env, *cmd)
          end
        end
      end

      private

      def prepare_files_in(dir)
        js = builder.to_s
        map = builder.source_map.to_json
        stack = File.binread("#{__dir__}/source-map-support-browser.js")

        ext = builder.output_extension
        module_type = ' type="module"' if builder.esm?

        # Some maps may contain `</script>` fragment (eg. in strings) which would close our
        # `<script>` tag prematurely. For this case, we need to escape the `</script>` tag.
        map_json = map.to_json.gsub(/(<\/scr)(ipt>)/i, '\1"+"\2')

        # Chrome can't handle huge data passed to `addScriptToEvaluateOnLoad`
        # https://groups.google.com/a/chromium.org/forum/#!topic/chromium-discuss/U5qyeX_ydBo
        # The only way is to create temporary files and pass them to chrome.
        File.binwrite("#{dir}/index.#{ext}", js)
        File.binwrite("#{dir}/index.map", map)
        File.binwrite("#{dir}/source-map-support.js", stack)
        File.binwrite("#{dir}/index.html", <<~HTML)
          <html><head>
            <meta charset='utf-8'>
            <link rel="shortcut icon" href="data:image/x-icon;," type="image/x-icon">
            <script src='./source-map-support.js'></script>
            <script>
            window.OPAL_EXIT_CODE = "noexit"
            sourceMapSupport.install({
              retrieveSourceMap: function(path) {
                return path.endsWith('/index.#{ext}') ? {
                  url: './index.map', map: #{map_json}
                } : null;
              }
            });
            </script>
          </head><body>
            <script src='./index.#{ext}'#{module_type}></script>
          </body></html>
        HTML
      end

      def chrome_host
        ENV['CHROME_HOST'] || ENV['OPAL_CDP_HOST'] || DEFAULT_CDP_HOST
      end

      def chrome_port
        ENV['CHROME_PORT'] || ENV['OPAL_CDP_PORT'] || DEFAULT_CDP_PORT
      end

      def with_chrome_server
        if chrome_server_running?
          yield
        else
          run_chrome_server { yield }
        end
      end

      def run_chrome_server
        raise 'Chrome server can be started only on localhost' if chrome_host != DEFAULT_CDP_HOST

        profile = mktmpprofile

        # Disable web security with "--disable-web-security" flag to be able to do XMLHttpRequest (see test_openuri.rb)
        # For other options see https://github.com/puppeteer/puppeteer/blob/main/packages/puppeteer-core/src/node/ChromeLauncher.ts
        chrome_server_cmd = %{#{OS.shellescape(chrome_executable)} \
          --allow-pre-commit-input \
          --disable-background-networking \
          --disable-background-timer-throttling \
          --disable-backgrounding-occluded-windows \
          --disable-breakpad \
          --disable-client-side-phishing-detection \
          --disable-component-extensions-with-background-pages \
          --disable-crash-reporter \
          --disable-default-apps \
          --disable-dev-shm-usage \
          --disable-extensions \
          --disable-features=Translate,AcceptCHFrame,MediaRouter,OptimizationHints \
          --disable-hang-monitor \
          --disable-infobars \
          --disable-ipc-flooding-protection \
          --disable-popup-blocking \
          --disable-prompt-on-repost \
          --disable-renderer-backgrounding \
          --disable-search-engine-choice-screen \
          --disable-sync \
          --disable-web-security \
          --enable-automation \
          --enable-blink-features=IdleDetection \
          --enable-features=PdfOopif \
          --export-tagged-pdf \
          --force-color-profile=srgb \
          --generate-pdf-document-outline \
          --headless \
          --hide-scrollbars \
          --metrics-recording-only \
          --mute-audio \
          --no-first-run \
          --password-store=basic \
          --use-mock-keychain \
          --user-data-dir=#{profile} \
          --remote-debugging-port=#{chrome_port} \
          #{ENV['CHROME_OPTS']}}

        chrome_pid = Process.spawn(chrome_server_cmd, in: OS.dev_null, out: OS.dev_null, err: OS.dev_null)

        Timeout.timeout(30) do
          loop do
            break if chrome_server_running?
            sleep 0.5
          end
        end

        yield
      rescue Timeout::Error
        puts 'Failed to start chrome server'
        puts 'Make sure that you have it installed and that its version is > 59'
        exit(1)
      ensure
        if OS.windows? && chrome_pid
          Process.kill('KILL', chrome_pid) unless system("taskkill /f /t /pid #{chrome_pid} >NUL 2>NUL")
        elsif chrome_pid
          Process.kill('HUP', chrome_pid)
        end
        FileUtils.rm_rf(profile) if profile
      end

      def chrome_server_running?
        puts "Connecting to #{chrome_host}:#{chrome_port}..."
        TCPSocket.new(chrome_host, chrome_port).close
        true
      rescue Errno::ECONNREFUSED, Errno::EADDRNOTAVAIL
        false
      end

      def chrome_executable
        ENV['GOOGLE_CHROME_BINARY'] ||
          if OS.windows?
            [
              'C:/Program Files/Google/Chrome Dev/Application/chrome.exe',
              'C:/Program Files/Google/Chrome/Application/chrome.exe'
            ].each do |path|
              next unless File.exist? path
              return path
            end
          elsif OS.macos?
            [
              '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
              '/Applications/Chromium.app/Contents/MacOS/Chromium'
            ].each do |path|
              next unless File.exist? path
              return path
            end
          else
            %w[
              google-chrome-stable
              chromium
              chromium-freeworld
              chromium-browser
            ].each do |name|
              next unless system('sh', '-c', "command -v #{name.shellescape}", out: '/dev/null')
              return name
            end
            raise 'Cannot find chrome executable'
          end
      end

      def mktmpdir(&block)
        Dir.mktmpdir('chrome-opal-', &block)
      end

      def mktmpprofile
        Dir.mktmpdir('chrome-opal-profile-')
      end
    end
  end
end
