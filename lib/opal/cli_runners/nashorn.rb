# frozen_string_literal: true

module Opal
  module CliRunners
    class Nashorn < Cmd
      def initialize(options)
        super(options, 'nashorn', {}, 'jjs')
      end

      def run(code, argv)
        super(code, argv)
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK to be able to run Opal scripts.'
      end

      class MissingNashorn < RunnerError
      end
    end
  end
end
