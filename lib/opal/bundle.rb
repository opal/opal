require "opal/builder"
require "fileutils"

module Opal
  class Bundle
    # The bundle name. For gems this will be the gem name, for
    # applications this should be something unique. It should ideally be
    # the same name you give in the lib/ folder.
    #
    # @return [String] bundle name
    attr_accessor :name

    # Version number for the bundle. Should be of the form "x.x.x". This
    # is optional.
    #
    # @return [String] version number
    attr_accessor :version

    # All files to bundle together. This defaults to a glob that looks for
    # `Dir['lib/**/*.rb'], i.e. all ruby files inside the lib/ directory.
    #
    # Additional files, or different files, may be added with:
    #
    #   bundle.files = Dir['lib/**/*.rb'] + ["main.rb"]
    #
    # All files **must** be relative to the bundle root, i.e. not contain
    # the full path - this helps in creating the lib paths etc.
    #
    # @return [Array<String>] all files to be compiled
    attr_writer :files

    # A Hash of parser options passed to each compile stage. This
    # accepts various options such as `:method_missing`. See [Parser]
    # for all options.
    #
    # @return [Hash] hash of parser options.
    attr_accessor :options

    # Path to use for tmp building. If given then all built files will
    # be written to this tmp location. This speeds up building as only
    # unmodified files need to be rebuilt between bundling.
    #
    # If not set then all ruby files will be built for every bundling.
    #
    # @return [String] temp path to build to
    attr_accessor :tmp_path

    # Inserted at top of bundle
    attr_accessor :header

    # Main file to require on load. This will always be inserted at the end
    # of the file to ensure any bundled dependencies are registered first
    #
    # Usage:
    #
    #   bundle.main = "my_project/main"
    #
    # @return [String] main file to load
    attr_accessor :main

    def initialize(root = Dir.getwd)
      @root = root
      @builder = Builder.new
      @options = {}
    end

    # lazy load default files - if we just set the files afterwards to
    # a completely new array, then we dont want to have to waste time
    # globbing in the first place.
    def files
      @files ||= Dir.chdir(@root) { Dir["lib/**/*.rb"] }
    end

    # Build the entire bundle
    def build
      libs = []
      files = []

      valid_files.each do |f|
        code = build_file File.expand_path(f, @root)

        if /^lib\// =~ f
          lib = f[4..f.length]
          libs << "#{lib.inspect}: #{code}"
        else
          files << "#{f.inspect}: #{code}"
        end
      end

      b = []
      b << @header if @header
      b << %[opal.bundle({\n]
      b << %[  name: "#{@name}",\n]
      b << %[  libs: {\n    #{libs.join ",\n    "}\n  },\n] unless libs.empty?
      b << %[  files: {\n    #{files.join ",\n    "}\n  }\n] unless files.empty?
      b << %[});\n]

      b << "opal.require('#{@main}', '#{@name}')\n" if @main

      b.join ''
    end

    private

    # Build a single source. This method works out if it must be written
    # to a tmp file or not, and if so checks whether it actually needs
    # to be compiled or not. Either way the result of this method is the
    # compiled string. The result is also then written to the temp file
    # (if needed).
    #
    # @param [String] path the path to the file to compile
    # @return [String] compiled ruby as a string
    def build_file(path)
      if @tmp_path
        out = File.join @tmp_path, path

        if true # should work out if we need to build. if src is newer than tmp
          code = @builder.parse File.read(path), @options
          FileUtils.mkdir_p File.dirname(out)
          File.open(out, "w+") { |o| o.write code }
        else
          code = File.read(out)
        end
      else
        code = @builder.parse File.read(path), @options
      end

      code
    end

    # Build an array of files to be added. This will look at @files, and use
    # those if defined, otherwise defaults to lib/**/*.rb
    #
    # MUST be relative.
    # FIXME: this should really make relative paths from absolute ones.
    #
    # @return [Array<String>]
    def valid_files
      puts files.inspect

      files
    end
  end
end

