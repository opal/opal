require 'shellwords'

module Opal
  module CliRunners
    class Phantomjs
      SCRIPT_PATH = File.expand_path('../phantom.js', __FILE__)

      def initialize(output: $stdout, **)
        @output = output
      end
      attr_reader :output, :exit_status

      def run(code, argv)
        unless argv.empty?
          raise ArgumentError, 'Program arguments are not supported on the PhantomJS runner'
        end

        phantomjs = IO.popen(command, 'w', out: output) do |io|
          io.write(code)
        end
        @exit_status = $?.exitstatus
      end

      def command
        "phantomjs #{SCRIPT_PATH.shellescape}"
      end
    end
  end
end
