# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'shellwords'

module Opal
  module CliRunners
    # QuickJS is Fabrice Bellard's minimalistic JavaScript engine
    # https://github.com/bellard/quickjs
    class Quickjs
      def self.call(data)
        exe = ENV['QJS_PATH'] || 'qjs'

        opts = Shellwords.shellwords(ENV['QJS_OPTS'] || '')

        SystemRunner.call(data) do |tempfile|
          [exe, '--std', *opts, tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingQuickjs, 'Please install QuickJS to be able to run Opal scripts.'
      end

      class MissingQuickjs < RunnerError
      end
    end
  end
end
