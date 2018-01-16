# frozen_string_literal: true
require 'opal/paths'

module Opal
  module CliRunners
    class Nodejs
      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)

      def initialize(options)
        command_options = {:name => 'nodejs', :env => {'NODE_PATH' => node_modules}, :cmd => 'node'}
        command_options[:options] = options
        @cmd = Cmd.new(command_options)
      end

      def puts(*args)
        @cmd.puts(*args)
      end

      def node_modules
        paths = ENV['NODE_PATH'].to_s.split(':')
        paths << NODE_PATH unless paths.include? NODE_PATH
        paths.join(':')
      end

      def run(code, argv)
        @cmd.run(code, argv)
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      def output
        @cmd.output
      end

      def exit_status
        @cmd.exit_status
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
