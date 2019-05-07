# frozen_string_literal: true

require 'opal/paths'
require 'shellwords'
require 'opal/cli_runners/generic_system_runner'

module Opal
  module CliRunners
    class Strictnodejs
      include GenericSystemRunner

      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)

      def initialize(options)
        @output = options.fetch(:output, $stdout)
        @tempfile_prefix = 'opal-strictnode-output'
      end
      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def node_modules
        paths = ENV['NODE_PATH'].to_s.split(':')
        paths << NODE_PATH unless paths.include? NODE_PATH
        paths.join(':')
      end

      def run(code, argv)
        require 'tempfile'
        # File.write('opal-strictnodejs-runner.js', code) # for debugging
        tempfile = Tempfile.new('opal-strictnodejs-runner-')
        tempfile.write code
        tempfile.close
        system_with_output({ 'NODE_PATH' => node_modules }, 'node', '--use-strict', tempfile.path, *argv)
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
