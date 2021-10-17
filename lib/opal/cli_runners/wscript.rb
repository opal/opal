# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'shellwords'

module Opal
  module CliRunners
    # WScript is a CLI Runner for Windows Scripting Host
    class Wscript
      def self.call(data)
        exe = ENV['WSCRIPT_PATH'] || 'cscript'

        opts = Shellwords.shellwords(ENV['WSCRIPT_OPTS'] || '')

        SystemRunner.call(data) do |tempfile|
          [exe, "//E:javascript", *opts, tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingWscript, 'Windows Scripting Host is available only on Windows'
      end

      class MissingWscript < RunnerError
      end
    end
  end
end
