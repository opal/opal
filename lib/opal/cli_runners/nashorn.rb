# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/generic_system_runner'

module Opal
  module CliRunners
    class Nashorn
      include GenericSystemRunner

      def initialize(options)
        @output = options.fetch(:output, $stdout)
        @tempfile_prefix = 'opal-nashorn-output'
      end
      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new('opal-nashorn-runner-')
        tempfile.write code
        tempfile.close
        system_with_output({}, 'jjs', tempfile.path, *argv)
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK to be able to run Opal scripts.'
      end

      class MissingNashorn < RunnerError
      end
    end
  end
end
