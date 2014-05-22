require 'shellwords'

module Opal
  module CliRunners
    class Phantomjs
      def initialize(output = $stdout)
        @output = output
      end
      attr_reader :output

      def run(code)
        phantomjs = IO.popen(command, 'w', out: output) do |io|
          io.write(code)
        end
        exit $?.exitstatus
      end

      def command
        script_path = File.expand_path('../phantom.js', __FILE__)
        "phantomjs #{script_path.shellescape}"
      end
    end
  end
end
