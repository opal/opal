# frozen_string_literal: true

require 'shellwords'
require 'socket'
require 'timeout'

module Opal
  module CliRunners
    class Chrome
      SCRIPT_PATH = File.expand_path('chrome.js', __dir__).freeze

      DEFAULT_CHROME_HOST = 'localhost'
      DEFAULT_CHROME_PORT = 9222

      def initialize(options)
        @output = options.fetch(:output, $stdout)
      end
      attr_reader :output, :exit_status

      def run(code, _argv)
        with_chrome_server do
          cmd = [
            'env',
            "CHROME_HOST=#{chrome_host}",
            "CHROME_PORT=#{chrome_port}",
            'node',
            SCRIPT_PATH
          ]

          IO.popen(cmd, 'w', out: output) do |io|
            io.write(code)
          end

          @exit_status = $?.exitstatus
        end
      end

      private

      def chrome_host
        ENV['CHROME_HOST'] || DEFAULT_CHROME_HOST
      end

      def chrome_port
        ENV['CHROME_PORT'] || DEFAULT_CHROME_PORT
      end

      def with_chrome_server
        if chrome_server_running?
          yield
        else
          run_chrome_server { yield }
        end
      end

      def run_chrome_server
        raise 'Chrome server can be started only on localhost' if chrome_host != DEFAULT_CHROME_HOST

        # Disable web security with "--disable-web-security" flag to be able to do XMLHttpRequest (see test_openuri.rb)
        chrome_server_cmd = "#{chrome_executable} --headless --disable-web-security --disable-gpu --remote-debugging-port=#{chrome_port} #{ENV['CHROME_OPTS']}"
        puts chrome_server_cmd

        chrome_pid = Process.spawn(chrome_server_cmd)

        Timeout.timeout(1) do
          loop do
            break if chrome_server_running?
            sleep 0.1
          end
        end

        yield
      rescue Timeout::Error
        puts 'Failed to start chrome server'
        puts 'Make sure that you have it installed and that its version is > 59'
      ensure
        Process.kill('HUP', chrome_pid) if chrome_pid
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
          case RbConfig::CONFIG['host_os']
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            raise 'Headless chrome is supported only by Mac OS and Linux'
          when /darwin|mac os/
            '/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
          when /linux/
            %w{
              google-chrome-stable
              chromium
            }.each do |name|
              next unless system('sh', '-c', "command -v #{name.shellescape}", out: '/dev/null')
              return name
            end
            raise "Cannot find chrome executable"
          when /solaris|bsd/
            raise 'Headless chrome is supported only by Mac OS and Linux'
          end
      end
    end
  end
end
