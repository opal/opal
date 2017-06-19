# frozen_string_literal: true
require 'shellwords'
require 'socket'
require 'timeout'

module Opal
  module CliRunners
    class Chrome
      SCRIPT_PATH = File.expand_path('../chrome.js', __FILE__)

      def initialize(options)
        @output = options.fetch(:output, $stdout)
      end
      attr_reader :output, :exit_status

      def run(code, argv)
        with_chrome_server do
          IO.popen(['node', SCRIPT_PATH], 'w', out: output) do |io|
            io.write(code)
          end

          @exit_status = $?.exitstatus
        end
      end

      private

      def with_chrome_server
        chrome_server_cmd = "#{chrome_executable} --headless --disable-gpu --remote-debugging-port=9222"
        puts chrome_server_cmd
        chrome_pid = Process.spawn(chrome_server_cmd)

        Timeout.timeout(1) do
          begin
            loop do
              puts "Connecting to localhost:9222..."
              TCPSocket.new('127.0.0.1', 9222).close
            end
          rescue Errno::ECONNREFUSED
            sleep 0.1
          end
        end

        yield
      rescue Timeout::Error
        puts 'Failed to start chrome server'
        puts 'Make sure that you have it installed and that its version is > 59'
      ensure
        Process.kill('HUP', chrome_pid)
      end

      def chrome_executable
        case RbConfig::CONFIG['host_os']
        when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
          raise "Headless chrome is supported only by Mac OS and Linux"
        when /darwin|mac os/
          "/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome"
        when /linux/
          'chrome'
        when /solaris|bsd/
          raise "Headless chrome is supported only by Mac OS and Linux"
        end
      end
    end
  end
end
