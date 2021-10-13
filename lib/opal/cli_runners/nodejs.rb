# frozen_string_literal: true

require 'shellwords'
require 'opal/paths'
require 'opal/cli_runners/system_runner'

module Opal
  module CliRunners
    class Nodejs
      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)

      def self.call(data)
        (data[:options] ||= {})[:env] = { 'NODE_PATH' => node_modules }

        argv = data[:argv].dup.to_a
        argv.unshift('--') if argv.any?

        opts = Shellwords.shellwords(ENV['NODE_OPTS'] || '')

        SystemRunner.call(data) do |tempfile|
          [
            'node',
            '--require', "#{__dir__}/source-map-support-node",
            *opts,
            tempfile.path,
            *argv
          ]
        end
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      # Ensure stdlib node_modules is among NODE_PATHs
      def self.node_modules
        npsep = Gem.win_platform? ? ';' : ':'
        ENV['NODE_PATH'].to_s.split(npsep).tap do |paths|
          paths << NODE_PATH unless paths.include? NODE_PATH
        end.join(npsep)
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
