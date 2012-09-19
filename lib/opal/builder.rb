require 'opal/parser'

module Opal

  # Used to build gems/libs/directories of opal code
  class Builder

    def initialize(options = {})
      @sources = Array(options[:files])
      @options = options
    end

    def build
      @dir    = File.expand_path(@options[:dir] || Dir.getwd)

      files = files_for @sources

      @files    = {}
      @requires = {}
      @parser   = Parser.new

      files.each { |f| build_file f }

      build_order(@requires).map { |r| @files[r] }.join("\n")
    end

    def files_for(sources)
      files = []

      sources.each do |s|
        s = File.expand_path(File.join @dir, s)
        if File.directory? s
          files.push *Dir[File.join(s, '**/*.{rb,js}')]
        elsif %w(.rb .js).include? File.extname(s)
          files << s
        end
      end

      files
    end

    # @param [Hash<Array<String>>] files hash of dependencies
    def build_order(files)
      all     = files.keys
      result  = []
      handled = {}

      all.each { |r| _find_build_order r, files, handled, result }
      result
    end

    def _find_build_order(file, files, handled, result)
      if handled[file] or !files[file]
        return
      end

      handled[file] = true

      files[file].each do |r|
        _find_build_order r, files, handled, result
      end

      result << file
    end

    def build_file(file)
      lib_name    = lib_name_for file
      parser_name = parser_name_for file

      if File.extname(file) == '.rb'
        code = @parser.parse File.read(file), lib_name
        @requires[lib_name] = @parser.requires
      else # javascript
        code = "function() {\n #{ File.read file }\n}"
        @requires[lib_name] = []
      end

      @files[lib_name] = "// #{ parser_name }\n#{ code }"
    end

    def parser_name_for(file)
      file.sub(/^#{@dir}\//, '')
    end

    def lib_name_for(file)
      file = file.sub(/^#{@dir}\//, '')
      file = file.chomp File.extname(file)
      file.sub(/^(lib|spec|app)\//, '')
    end
  end
end