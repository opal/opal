module Opal
  module Util
    extend self

    # Used for uglifying source to minify
    def uglify(str)
      uglifyjs = DigestSourceCommand.new(:uglifyjs, nil, ' (install with: "npm install -g uglify-js")')
      uglifyjs.digest(str)
    end

    # Gzip code to check file size
    def gzip(str)
      gzip = DigestSourceCommand.new(:gzip, '-f', ', it is required to produce the .gz version')
      gzip.digest(str)
    end


    class DigestSourceCommand
      def initialize(command, options, message)
        @command, @options, @message = command, options, message
      end
      attr_reader :command, :options, :message

      def digest(source)
        return unless command_installed? command, message
        IO.popen("#{command} #{options} #{hide_stderr}", 'r+') do |i|
          i.puts source
          i.close_write
          i.read
        end
      end


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
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable? exe
          }
        end
        nil
      end

      INSTALLED = {}
      def command_installed?(cmd, install_comment)
        cmd = cmd.to_s
        INSTALLED.fetch(cmd) do
          unless INSTALLED[cmd] = which(cmd) != nil
            $stderr.puts %Q("#{cmd}" command not found#{install_comment})
          end
        end
      end
    end

  end
end
