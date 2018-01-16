# frozen_string_literal: true
require 'shellwords'

module Opal
  module CliRunners
    class Cmd
      def initialize(command_options)
        @output = (command_options[:options] || {}).fetch(:output, $stdout)
        @name = command_options[:name]
        @env = command_options[:env] || {}
        @cmd = command_options[:cmd]
      end

      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new("opal-#{@name}-runner")
        # tempfile = File.new("opal-#{@name}-runner.js", 'w') # for debugging
        tempfile.write code
        tempfile.close
        system_with_output(@env, *@cmd, tempfile.path, *argv)
      end

      # Let's support fake IO objects like StringIO
      def system_with_output(env, *cmd)
        if IO.try_convert(output)
          system(env, *cmd)
          @exit_status = $?.exitstatus
          return
        end

        if RUBY_PLATFORM == 'java'
          # JRuby has issues in dealing with subprocesses (at least up to 1.7.15)
          # @headius told me it's mostly fixed on master, but while we wait for it
          # to ship here's a tempfile workaround.
          require 'tempfile'
          tempfile = Tempfile.new("opal-#{@name}-runner")
          system(env, cmd.shelljoin+" > #{tempfile.path}")
          @exit_status = $?.exitstatus
          captured_output = File.read tempfile.path
          tempfile.close
        else
          require 'open3'
          captured_output, status = Open3.capture2(env, *cmd)
          @exit_status = status.exitstatus
        end

        output.write captured_output
      end
    end
  end
end
