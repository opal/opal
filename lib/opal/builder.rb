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
      corelib = Opal.parse corelib.join("\n")

      [
        "/*!",
        " * Opal v#{Opal::VERSION}",
        " * http://opalrb.org",
        " *",
        " * Copyright 2012, Adam Beynon",
        " * Released under the MIT License",
        " */",
        "(function(undefined) {",
        runtime,
        "var method_names = {#{ methods.join ', ' }},",
        "reverse_method_names = {};",
        "for (var id in method_names) {",
        "reverse_method_names[method_names[id]] = id;",
        "}",
        corelib,
        "}).call(this);"
      ].join("\n")
    end

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
          files.push *Dir[File.join s, '**/*.{rb,js}']
        elsif File.extname(s) == '.rb' or File.extname(s) == ".js"
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
      if File.extname(file) == '.rb'
        @parser.parse File.read(file)
      else
        File.read file
      end
    end
  end
end