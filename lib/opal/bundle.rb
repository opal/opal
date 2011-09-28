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

    def initialize(root = Dir.getwd)
      @root = root
      @builder = Builder.new
      @options = {}
    end

    # Build the entire bundle
    def build
      libs = lib_files.map do |lib|
        code = build_file File.expand_path(lib, @root)
        path = lib[4, lib.length - 7]
        "\"#{path}\": #{code}"
      end

      bundle = []
      bundle << %[opal.gem({\n]
      bundle << %[  name: "#{@name}",\n]
      bundle << %[  version: "#{@version}",\n]
      bundle << %[  libs: {\n]
      bundle << %[    #{libs.join ",\n    "}\n]
      bundle << %[  }\n]
      bundle << %[});\n]

      bundle.join ''
    end

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

    # Returns an array of all lib files for this bundle. These are all
    # relative paths.
    #
    # Usage:
    #
    #     bundle.lib_files
    #     # => ["lib/app.rb", "lib/app/user.rb", "lib/app/view.rb"]
    #
    # @return [Array<String>] array of paths
    def lib_files
      Dir.chdir(@root) { Dir["{lib}/**/*.rb"] }
    end
  end
end

