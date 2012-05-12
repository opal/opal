require 'fileutils'

module Opal
  class Builder
    def initialize(options = {})
      @sources = Array(options[:files])
      @options = options
    end

    def build
      unless out = @options[:out]
        # ...
        out = "out.js"
      end

      # puts "  - Building to #{out}"

      files = files_for @sources

      # puts "  - files: #{files.inspect}"

      FileUtils.mkdir_p File.dirname(out)

      build_to files, out
    end

    def files_for(sources)
      files = []

      sources.each do |s|
        if File.directory? s
          files.push *Dir[File.join s, '**/*.rb']
        elsif File.extname(s) == '.rb'
          files << s
        end
      end

      files
    end

    def build_to(files, out)
      @parser = Parser.new

      File.open(out, 'w+') do |o|
        files.each { |file| o.puts build_file(file) }
      end
    end

    def build_file(file)
      @parser.parse File.read(file)
    end
  end
end