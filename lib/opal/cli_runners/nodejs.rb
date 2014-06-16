require 'opal/cli_runners'

module Opal
  module CliRunners
    class Nodejs
      def initialize(output)
        @output ||= output
      end
      attr_reader :output

      def puts(*args)
        output.puts(*args)
      end

      def node_modules
        File.expand_path("../../../node_modules", __FILE__)
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new('opal-nodejs-runner-')
        tempfile.write code
        tempfile.flush

        require 'open3'
        begin
          stdin, stdout, stderr = Open3.popen3({'NODE_PATH' => node_modules}, 'node', tempfile.path , *argv)
        rescue Errno::ENOENT
          raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
        end

        stdin.close

        [stdout, stderr].each do |io|
          str = io.read
          puts str unless str.empty?
        end
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
