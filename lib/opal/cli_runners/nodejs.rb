# frozen_string_literal: true
require 'opal/paths'

module Opal
  module CliRunners
    class Nodejs < Cmd
      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)

      def initialize(options)
        super(options, 'nodejs', {'NODE_PATH' => node_modules}, 'node')
      end

      def puts(*args)
        output.puts(*args)
      end

      def node_modules
        NODE_PATH
      end

      def run(code, argv)
        super(code, argv)
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
