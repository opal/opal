require 'fileutils'

module Opal
  class Builder
    def initialize(sources, options = {})
      @sources = Array(sources)
      @options = options

      @options[:output] = '.' if @options[:output] == '' or !@options[:output]
    end

    def build
      @parser     = Parser.new
      @factories  = {}

      @sources.each { |s| build_source '.', s }

      if @options[:join]
        File.open(@options[:join], 'w+') do |o|
          @factories.each { |path, factory| o.write factory }
        end
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
      path  = File.join base, source
      code  = @parser.parse File.read(path), path

      if /^lib/ =~ path
        code = "opal.lib('#{path[4..-4]}', function() {\n#{code}\n});\n"
      else
        code = "opal.file('#{path}', function() {\n#{code}\n});\n"
      end

      if @options[:join]
        @factories[path] = code
      elsif @options[:output]
        output = output_path base, source

        FileUtils.mkdir_p File.dirname(output)
        File.open(output, 'w+') { |o| o.write code }
      end
    end

    def output_path(base, source)
        fname = source.chomp('.rb') + '.js'
      if @options[:output] == '.'
        base == '.' ? fname : File.join(base, fname)
      else
        if base == '.'
          File.join @options[:output], fname
        else
          parts = base.split '/'
          parts[0] = @options[:output]
          parts << fname
          File.join *parts
        end
      end
    end
  end
end
