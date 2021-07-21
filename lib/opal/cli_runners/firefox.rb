require 'opal/cli_runners/chrome'

module Opal
  module CliRunners
    class Firefox < Chrome
      SCRIPT_PATH = File.expand_path('firefox.js', __dir__).freeze

      def script_path
        SCRIPT_PATH
      end

      def chrome_executable
        ENV['FIREFOX_BINARY'] ||
          case RbConfig::CONFIG['host_os']
          when 'linux'
            %w[
              firefox
              iceweasel
            ].each do |name|
              next unless system('sh', '-c', "command -v #{name.shellescape}", out: '/dev/null')
              return name
            end
            raise 'Cannot find Firefox executable'
          else
            raise 'Headless Firefox is supported only by Linux'
          end
      end

      def mktmpdir(&block)
        Dir.mktmpdir('firefox-opal-', &block)
      end
    end
  end
end