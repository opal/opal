require 'fileutils'

module Opal
  class Builder
    def initialize(sources, options = {})
      @sources = Array(sources)
      @options = options
    end

    def build
      @parser     = Parser.new @options
      @factories  = {}

      raise "No files given" if @sources.empty?
      puts "Building #{@sources.inspect} #{@options.inspect}"

      @sources.each { |s| build_source '.', s }

      unless out = @options[:out]
        if @sources == ['lib']
          out = File.basename(Dir.getwd)
        elsif @sources.include? 'spec'
          out = File.basename(Dir.getwd) + '.test'
        elsif @sources.size == 1
          out = File.basename(@sources[0], '.*')
        else
          out = File.basename(@sources[0], '.*')
        end

        out += '.debug' if @options[:debug]
        out += '.js'
      end

      puts "Writing to #{out}"
      FileUtils.mkdir_p File.dirname(out)

      File.open(out, 'w+') do |o|
        @factories.each { |path, factory| o.write factory }
      end
    end

    def build_source(base, source)
      path = base == '.' ? source : File.join(base, source)

      if File.directory? path
        Dir.entries(path).each do |e|
          next if e == '.' or e == '..'
          build_source path, e
        end

      elsif File.extname(path) == '.rb'
        build_file base, source
      end
    end

    def build_file(base, source)
      path  = base == '.' ? source : File.join(base, source)
      code  = @parser.parse File.read(path), path

      if /^lib/ =~ path
        code = "opal.lib('#{path[4..-4]}', function() {\n#{code}\n});\n"
      else
        code = "opal.file('/#{path}', function() {\n#{code}\n});\n"
      end

      @factories[path] = code
    end
  end
end
