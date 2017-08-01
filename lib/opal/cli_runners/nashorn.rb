# frozen_string_literal: true
require 'opal/paths'

module Opal
  module CliRunners
    class Nashorn
      def initialize(options)
        @output = options.fetch(:output, $stdout)
      end
      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new('opal-nashorn-runner-')
        tempfile.write code
        tempfile.close
        system_with_output({}, 'jjs', tempfile.path , *argv)
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK to be able to run Opal scripts.'
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
          tempfile = Tempfile.new('opal-nashorn-output')
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

      class MissingNashorn < RunnerError
      end
    end
  end
end
