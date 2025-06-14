# frozen_string_literal: true

require 'shellwords'
require 'opal/paths'
require 'opal/cli_runners/system_runner'
require 'opal/os'

module Opal
  module CliRunners
    class Nodejs
      if RUBY_ENGINE == 'opal'
        # We can't rely on Opal.gem_dir for now...
        DIR = './lib/opal/cli_runners'
      else
        DIR = __dir__
      end

      def self.call(data)
        argv = data[:argv].dup.to_a
        argv.unshift('--') if argv.any?

        opts = Shellwords.shellwords(ENV['NODE_OPTS'] || '')
        flame = ENV['NODE_FLAME']

        SystemRunner.call(data) do |tempfile|
          args = [
            'node',
            '--require', "#{DIR}/source-map-support-node",
            *opts,
            tempfile.path,
            *argv
          ]
          args.unshift('0x', '--') if flame
          args
        end
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
