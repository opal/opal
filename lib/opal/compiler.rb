require 'fileutils'

module Opal
  class Compiler
    def initialize(sources, options = {})
      @sources = Array(sources)
      @options = options
    end

    def compile
      @parser     = Parser.new
      @join_files = {}

      @sources.each { |s| compile_path s }

      if @options[:join]
        files = @join_files.to_a.map { |f| "'/#{f[0]}': #{f[1]}" }.join(",\n")
        File.open(@options[:join], 'w+') do |o|
          o.write "opal.register({\n#{files}\n});"
        end
      end
    end

    def compile_path(path)
      if File.directory? path
        Dir.entries(path).each do |e|
          next if e == '.' or e == '..'
          compile_path File.join(path, e)
        end

      elsif File.extname(path) == '.rb'
        compile_file path
      end
    end

    def compile_file(source)
      compiled = @parser.parse File.read(source), source

      if @options[:output]
        output = output_path(source)

        FileUtils.mkdir_p File.dirname(output)
        File.open(output, 'w+') { |o| o.write "(#{compiled}).call(opal.top, '', opal)" }

      elsif @options[:join]
        @join_files[source] = compiled
      end
    end

    def output_path(source)
      File.join(@options[:output], source.chomp('.rb')) + '.js'
    end
  end
end
