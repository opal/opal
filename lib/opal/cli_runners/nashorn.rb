# frozen_string_literal: true

module Opal
  module CliRunners
    class Nashorn
      def initialize(options)
        command_options = {:name => 'nashorn', :cmd => 'jjs'}
        command_options[:options] = options
        @cmd = Cmd.new(command_options)
      end

      def run(code, argv)
        @cmd.run(code, argv)
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK to be able to run Opal scripts.'
      end

      def output
        @cmd.output
      end

      def exit_status
        @cmd.exit_status
      end

      class MissingNashorn < RunnerError
      end
    end
  end
end
