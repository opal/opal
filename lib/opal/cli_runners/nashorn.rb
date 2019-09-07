# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/system_runner'

module Opal
  module CliRunners
    class Nashorn
      def self.call(data)
        # Allow to change path if using GraalVM, see:
        # https://github.com/graalvm/graaljs/blob/master/docs/user/NashornMigrationGuide.md#launcher-name-js
        exe = ENV['NASHORN_PATH'] || 'jjs'

        SystemRunner.call(data) do |tempfile|
          [exe, tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK or GraalVM to be able to run Opal scripts.'
      end

      class MissingNashorn < RunnerError
      end
    end
  end
end
