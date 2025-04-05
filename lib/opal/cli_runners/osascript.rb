# frozen_string_literal: true

require 'opal/cli_runners/system_runner'

module Opal
  module CliRunners
    class OSAScript
      class MissingOSAScript < RunnerError
      end

      def self.call(data)
        unless system('which osalang > /dev/null')
          raise MissingOSAScript, 'JavaScript Automation is only supported by OS X Yosemite and above.'
        end

        SystemRunner.call(data) do |tempfile|
          tempfile.puts "'';" # OSAScript will always output the last thing
          ['osascript', '-l', 'JavaScript', tempfile.path, *data[:argv]]
        end
      rescue Errno::ENOENT
        raise MissingOSAScript, 'OSAScript is only supported by OS X Yosemite and above.'
      end
    end
  end
end
