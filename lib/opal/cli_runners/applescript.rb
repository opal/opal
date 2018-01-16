# frozen_string_literal: true

module Opal
  module CliRunners
    class Applescript
      def initialize(options)
        unless system('which osalang > /dev/null')
          raise MissingJavaScriptSupport, 'JavaScript Automation is only supported by OS X Yosemite and above.'
        end
        command_options = {:name => 'applescript', :cmd => ['osascript', '-l', 'JavaScript']}
        command_options[:options] = options
        @cmd = Cmd.new(command_options)
      end

      def puts(*args)
        @cmd.puts(args)
      end

      def run(code, argv)
        osascript_code = "#{code}\n'';" # OSAScript will output the last thing
        @cmd.run(osascript_code, argv)
      rescue Errno::ENOENT
        raise MissingAppleScript, 'AppleScript is only available on Mac OS X.'
      end

      def output
        @cmd.output
      end

      def exit_status
        @cmd.exit_status
      end

      class MissingJavaScriptSupport < RunnerError
      end

      class MissingAppleScript < RunnerError
      end
    end
  end
end
