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
        # Allow to change path if using GraalVM, see:
        # https://github.com/graalvm/graaljs/blob/master/docs/user/NashornMigrationGuide.md#launcher-name-js
        exe = ENV['NASHORN_PATH'] || 'jjs'

        require 'tempfile'
        tempfile = Tempfile.new('opal-nashorn-runner-')
        tempfile.write code
        tempfile.close
        system_with_output({}, exe, tempfile.path, *argv)
      rescue Errno::ENOENT
        raise MissingNashorn, 'Please install JDK or GraalVM to be able to run Opal scripts.'
      end

      # Let's support fake IO objects like StringIO
      def system_with_output(env, *cmd)
        if IO.try_convert(output)
          system(env, *cmd)
          @exit_status = $?.exitstatus
          return
        end

        require 'open3'
        captured_output, status = Open3.capture2(env, *cmd)
        @exit_status = status.exitstatus

        output.write captured_output
      end

      class MissingNashorn < RunnerError
      end
    end
  end
end
