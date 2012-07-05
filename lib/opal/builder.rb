require 'fileutils'

module Opal
  class Builder
    def self.runtime
      core_dir   = Opal.core_dir
      load_order = File.join core_dir, 'load_order'
      result     = []
      corelib    = File.read(load_order).strip.split.map do |c|
        File.read File.join(core_dir, "#{c}.rb")
      end

      methods = Parser::METHOD_NAMES.map { |f, t| "'#{f}': '$#{t}$'" }
      runtime = File.read(File.join core_dir, 'runtime.js')
      corelib = Opal.parse corelib.join("\n"), '(corelib)'

      [
        "// Opal v#{Opal::VERSION}",
        "// http://opalrb.org",
        "// Copyright 2012, Adam Beynon",
        "// Released under the MIT License",
        "(function(undefined) {",
        runtime,
        "var method_names = {#{ methods.join ', ' }};",
        "Opal.version = #{ Opal::VERSION.inspect };",
        corelib,
        "}).call(this);"
      ].join("\n")
    end

    def self.build(opts)
      self.new(opts).build
    end

    def initialize(options = {})
      @sources = Array(options[:files])
      @options = options
    end

    def build
      @dir = File.expand_path(@options[:dir] || Dir.getwd)

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
        s = File.join @dir, s
        if File.directory? s
          files.push *Dir[File.join s, '**/*.{rb,js}']
        elsif File.extname(s) == '.rb' or File.extname(s) == ".js"
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
      else
        code = File.read file
        @requires[lib_name] = []
      end

      @files[lib_name] = "// file #{ parser_name }\n#{ code }"
    end

    def parser_name_for(file)
      file.sub /^#{@dir}\//, ''
    end

    def lib_name_for(file)
      file = file.sub /^#{@dir}\//, ''
      file = file.chomp File.extname(file)
      file.sub /^lib\/(opal\/)?/, ''
    end
  end
end