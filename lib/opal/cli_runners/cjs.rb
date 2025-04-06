# frozen_string_literal: true

require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'shellwords'

module Opal
  module CliRunners
    # Cjs is Cinnamon's JavaScript runtime based on Mozilla SpiderMonkey
    class Cjs
      def self.call(data)
        exe = ENV['CJS_PATH'] || 'cjs'
        builder = data[:builder].call

        opts = Shellwords.shellwords(ENV['CJS_OPTS'] || '')
        opts.unshift('-m') if builder.esm?

        SystemRunner.call(data.merge(builder: -> { builder })) do |tempfile|
          [exe, *opts, tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingCjs, 'Please install Cjs to be able to run Opal scripts.'
      end

      class MissingCjs < RunnerError
      end
    end
  end
end
