require 'fileutils'

module Opal
  class Builder
    def self.runtime
      core_dir   = Opal.core_dir
      load_order = File.join core_dir, 'load_order'
      corelib    = File.read(load_order).strip.split.map do |c|
        File.read File.join(core_dir, "#{c}.rb")
      end

      runtime = File.read(File.join core_dir, 'runtime.js')
      corelib = Opal.parse corelib.join("\n"), '(corelib)'

      [
        "// Opal v#{Opal::VERSION}",
        "// http://opalrb.org",
        "// Copyright 2012, Adam Beynon",
        "// Released under the MIT License",
        "(function(undefined) {",
        runtime,
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
      @dir    = File.expand_path(@options[:dir] || Dir.getwd)
      @parser = Parser.new
      
      files_for(@sources).map { |f| build_file f }.join("\n")
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

    def build_file(file)
      lib_name    = lib_name_for file
      parser_name = parser_name_for file

      if File.extname(file) == '.rb'
        code = @parser.parse File.read(file), parser_name
      else
        code = "function() {\n #{ File.read file }\n}"
      end

      "Opal.define(#{ lib_name.inspect }, #{ code });"
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