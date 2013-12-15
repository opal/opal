module Opal
  module Util
    extend self

    # Used for uglifying source to minify
    def uglify(str)
      IO.popen('uglifyjs 2> /dev/null', 'r+') do |i|
        i.puts str
        i.close_write
        return i.read
      end
    rescue Errno::ENOENT
      $stderr.puts '"uglifyjs" command not found (install with: "npm install -g uglify-js")'
      nil
    end

    # Gzip code to check file size
    def gzip(str)
      IO.popen('gzip -f 2> /dev/null', 'r+') do |i|
        i.puts str
        i.close_write
        return i.read
      end
    rescue Errno::ENOENT
      $stderr.puts '"gzip" command not found, it is required to produce the .gz version'
      nil
    end
  end
end
