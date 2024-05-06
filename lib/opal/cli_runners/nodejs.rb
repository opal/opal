# frozen_string_literal: true

require 'shellwords'
require 'opal/cli_runners/system_runner'
require 'opal/os'

module Opal
  module CliRunners
    class Nodejs
      if RUBY_ENGINE == 'opal'
        # We can't rely on Opal.gem_dir for now...
        NODE_PATH = 'stdlib/nodejs/node_modules'
        DIR = './lib/opal/cli_runners'
      else
        NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)
        DIR = __dir__
      end

      def self.call(data)
        (data[:options] ||= {})[:env] = { 'NODE_PATH' => node_modules }

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

      # Ensure stdlib node_modules is among NODE_PATHs
      def self.node_modules
        ENV['NODE_PATH'].to_s.split(OS.env_sep).tap do |paths|
          paths << NODE_PATH unless paths.include? NODE_PATH
        end.join(OS.env_sep)
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
