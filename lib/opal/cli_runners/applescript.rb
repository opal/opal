# frozen_string_literal: true

require 'opal/cli_runners/system_runner'

module Opal
  module CliRunners
    class Applescript
      def self.call(data)
        unless system('which osalang > /dev/null')
          raise MissingJavaScriptSupport, 'JavaScript Automation is only supported by OS X Yosemite and above.'
        end

        SystemRunner.call(data) do |tempfile|
          tempfile.puts "'';" # OSAScript will output the last thing
          ['osascript', '-l', 'JavaScript', tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingAppleScript, 'AppleScript is only available on Mac OS X.'
      end

      class MissingJavaScriptSupport < RunnerError
      end

      class MissingAppleScript < RunnerError
      end
    end
  end
end
