# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'shellwords'

module Opal
  module CliRunners
    # Gjs is GNOME's JavaScript runtime based on Mozilla SpiderMonkey
    class Gjs
      def self.call(data)
        exe = ENV['GJS_PATH'] || 'gjs'

        opts = Shellwords.shellwords(ENV['GJS_OPTS'] || '')

        SystemRunner.call(data) do |tempfile|
          [exe, *opts, tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingGjs, 'Please install Gjs to be able to run Opal scripts.'
      end

      class MissingGjs < RunnerError
      end
    end
  end
end
