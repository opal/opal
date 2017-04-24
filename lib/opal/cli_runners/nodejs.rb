# frozen_string_literal: true
require 'opal/cli_runners'
require 'opal/paths'
require 'shellwords'

module Opal
  module CliRunners
    class Nodejs
      NODE_PATH = File.expand_path('../stdlib/nodejs/node_modules', ::Opal.gem_dir)

      def initialize(options)
        @output = options.fetch(:output, $stdout)
      end
      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def node_modules
        NODE_PATH
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new('opal-nodejs-runner-')
        # tempfile = File.new('opal-nodejs-runner.js', 'w') # for debugging
        tempfile.write code
        tempfile.close
        node_opt = ENV['NODE_OPT'].to_s.shellsplit
        system_with_output({'NODE_PATH' => node_modules}, 'node', *node_opt, tempfile.path, *argv)
      rescue Errno::ENOENT
        raise MissingNodeJS, 'Please install Node.js to be able to run Opal scripts.'
      end

      # Let's support fake IO objects like StringIO
      def system_with_output(env, *cmd)
        if IO.try_convert(output)
          system(env,*cmd)
          @exit_status = $?.exitstatus
          return
        end

        if RUBY_PLATFORM == 'java'
          # JRuby has issues in dealing with subprocesses (at least up to 1.7.15)
          # @headius told me it's mostly fixed on master, but while we wait for it
          # to ship here's a tempfile workaround.
          require 'tempfile'
          require 'shellwords'
          tempfile = Tempfile.new('opal-node-output')
          system(env,cmd.shelljoin+" > #{tempfile.path}")
          @exit_status = $?.exitstatus
          captured_output = File.read tempfile.path
          tempfile.close
        else
          require 'open3'
          captured_output, status = Open3.capture2(env,*cmd)
          @exit_status = status.exitstatus
        end

        output.write captured_output
      end

      class MissingNodeJS < RunnerError
      end
    end
  end
end
