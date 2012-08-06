require 'fileutils'
require 'opal/parser'

module Opal

  # Custom Opal::Parser subclass that is used to customize the
  # handling of require statements.
  class BuilderParser < Parser

    # Array of all requires from this file
    attr_reader :requires

    # Setup @requires array of all files this file requires.
    def parse(source, file = '(file)')
      @requires = []
      super source, file
    end

    # This gets given the arglist:
    #
    #   s(:arglist, s(:str, 'foo'))
    #
    # This method will only try and handle real strings given as an
    # argument. Any dynamic requires will be ignored.
    #
    # @return [String] string the parser should output
    def handle_require(arglist)
      path = arglist[1]

      if path and path[0] == :str
        path_name = path[1].sub(/^opal\//, '')
        @requires << path_name
      end

      return ""
    end
  end

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
      @parser   = BuilderParser.new

      files.each { |f| build_file f }

      build_order(@requires).map { |r| @files[r] }.join("\n")
    end

    def files_for(sources)
      files = []

      sources.each do |s|
        s = File.join @dir, s
        if File.directory? s
          files.push *Dir[File.join s, '**/*.{rb,js,erb}']
        elsif %w(.rb .js .erb).include? File.extname(s)
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
        code = @parser.parse File.read(file), parser_name
        @requires[lib_name] = @parser.requires
      elsif File.extname(file) == '.erb'
        template_name = File.basename(file).chomp(File.extname(file))
        code = Opal::ERBParser.new.parse File.read(file), template_name
        @requires[lib_name] = []
      else # javascript
        code = "function() {\n #{ File.read file }\n}"
        @requires[lib_name] = []
      end

      @files[lib_name] = "// #{ parser_name }\n(#{ code })();"
    end

    def parser_name_for(file)
      file.sub /^#{@dir}\//, ''
    end

    def lib_name_for(file)
      file = file.sub /^#{@dir}\//, ''
      file = file.chomp File.extname(file)
      file.sub /^lib\//, ''
    end
  end
end