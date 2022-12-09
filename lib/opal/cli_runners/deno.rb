# frozen_string_literal: true

require 'shellwords'
require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'opal/os'

module Opal
  module CliRunners
    class Deno
      def self.call(data)
        argv = data[:argv].dup.to_a

        SystemRunner.call(data) do |tempfile|
          [
            'deno',
            'run',
            '--allow-read',
            '--allow-write',
            tempfile.path,
            *argv
          ]
        end
      rescue Errno::ENOENT
        raise MissingDeno, 'Please install Deno to be able to run Opal scripts.'
      end

      class MissingDeno < RunnerError
      end
    end
  end
end
