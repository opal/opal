require 'opal/cli_runners'

module Opal
  module CliRunners
    class AppleScript
      def initialize(output)
        unless system('which osalang > /dev/null')
          raise MissingJavaScriptSupport, 'JavaScript Automation is only supported by OS X Yosemite and above.'
        end

        @output ||= output
      end
      attr_reader :output, :exit_status

      def puts(*args)
        output.puts(*args)
      end

      def run(code, argv)
        require 'tempfile'
        tempfile = Tempfile.new('opal-applescript-runner-')
        # tempfile = File.new('opal-applescript-runner.js', 'w') # for debugging
        tempfile.write code
        tempfile.close
        successful = system_with_output('osascript', '-l', 'JavaScript', tempfile.path , *argv)

      rescue Errno::ENOENT
        raise MissingAppleScript, 'AppleScript is only available on Mac OS X.'
      end

      # Let's support fake IO objects like StringIO
      def system_with_output(env, *cmd)
        if (io_output = IO.try_convert(output))
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
          tempfile = Tempfile.new('opal-applescript-output')
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

      class MissingJavaScriptSupport < RunnerError
      end

      class MissingAppleScript < RunnerError
      end
    end
  end
end
