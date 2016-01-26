require 'shellwords'

module Opal
  module CliRunners
    class Phantomjs
      SCRIPT_PATH = File.expand_path('../phantom.js', __FILE__)

      def initialize(options)
        @output = options.fetch(:output, $stdout)
      end
      attr_reader :output, :exit_status

      def run(code, argv)
        command = [
          'phantomjs',
          SCRIPT_PATH.shellescape,
          *argv.map(&:shellescape)
        ].join(' ')

        phantomjs = IO.popen(command, 'w', out: output) do |io|
          io.write(code)
        end

        @exit_status = $?.exitstatus
      end
    end
  end
end
