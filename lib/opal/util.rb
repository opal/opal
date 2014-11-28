module Opal
  module Util
    extend self

    # Used for uglifying source to minify.
    #
    #     Opal::Util.uglify("javascript contents")
    #
    # @param str [String] string to minify
    # @return [String]
    def uglify(str)
      uglifyjs = DigestSourceCommand.new(:uglifyjs, nil, ' (install with: "npm install -g uglify-js")')
      uglifyjs.digest(str)
    end

    # Gzip code to check file size.
    def gzip(str)
      gzip = DigestSourceCommand.new(:gzip, '-f', ', it is required to produce the .gz version')
      gzip.digest(str)
    end

    class Command
      def initialize(command, options, message = nil)
        @command, @options, @message = command, options, message
        return unless command_installed? command, message
      end
      attr_reader :command, :options, :message

      private

      def hide_stderr
        if (/mswin|mingw/ =~ RUBY_PLATFORM).nil?
          '2> /dev/null'
        else
          '2> nul'
        end
      end

      # Code from http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).find do |path|
          exts.find { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            exe if File.executable? exe
          }
        end
      end

      INSTALLED = {}
      def command_installed?(cmd, install_comment)
        command_installed = Command::INSTALLED[cmd.to_s] ||= which(cmd)
        $stderr.puts %Q("#{cmd}" command not found#{install_comment}) unless command_installed
        command_installed
      end
    end

    class DigestSourceCommand < Command
      def digest(source)
        IO.popen("#{command} #{options} #{hide_stderr}", 'r+') do |i|
          i.puts source
          i.close_write
          i.read
        end
      end
    end

  end
end
