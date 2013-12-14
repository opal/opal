module Opal
  module Util
    extend self

    # Used for uglifying source to minify
    def uglify(str)
      return unless command_installed? :uglifyjs, ' (install with: "npm install -g uglify-js")'
      IO.popen("uglifyjs 2> #{null}", 'r+') do |i|
        i.puts str
        i.close_write
        i.read
      end
    end

    # Gzip code to check file size
    def gzip(str)
      return unless command_installed? :gzip, ', it is required to produce the .gz version'
      IO.popen("gzip -f 2> #{null}", 'r+') do |i|
        i.puts str
        i.close_write
        i.read
      end
    end


    private

    def null
      if (/mswin|mingw/ =~ RUBY_PLATFORM).nil?
        '/dev/null'
      else
        'nul'
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
      INSTALLED.fetch(cmd) do
        unless INSTALLED[cmd] = which(cmd) != nil
          $stderr.puts %Q("#{cmd}" command not found#{install_comment})
        end
      end
    end
  end
end
