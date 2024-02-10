# frozen_string_literal: true

require 'shellwords'
require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'opal/os'

module Opal
  module CliRunners
    class Bun
      def self.call(data)
        argv = data[:argv].dup.to_a

        SystemRunner.call(data) do |tempfile|
          [
            'bun',
            'run',
            tempfile.path,
            *argv
          ]
        end
      rescue Errno::ENOENT
        raise MissingBun, 'Please install Bun to be able to run Opal scripts.'
      end

      class MissingBun < RunnerError
      end
    end
  end
end
