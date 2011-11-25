require 'opal'
require 'opal/bundle'
require 'opal/parser'
require 'fileutils'

module Opal
  ##
  # Handler for `opal build` command. This class is in charge of just
  # building an opal application. It relies on an Opalfile which
  # contains all the build options needed for building.

  class Builder
    ##
    # Main Bundle used

    attr_reader :bundle

    ##
    # A hash of all the bundles (gems) we know about.

    attr_reader :bundles

    # Initialize the build class with the application root given
    # by `root'.
    #
    # @param [String] root application root.
    def initialize(root = Dir.getwd)
      @root   = root
      @base   = File.basename @root

      @parser = Parser.new
      @bundle = Bundle.load @root
    end

    def reset
      @built_bundles = [] # array of bundle names already built (Strings)
      @built_stdlib  = [] # array of stdlib names already built
      @built_code    = [] # array of strings to be used in output

      yaml = File.join OPAL_DIR, 'build', 'data.yml'

      unless File.exists? yaml
        abort "opal.js must be built first. Run `rake opal` in opal root directory"
      end

      @parser.parse_data = YAML.load File.read(yaml)
    end

    ##
    # Actually build this.

    def build *args
      reset

      mode = (args.first || @bundle.default).to_sym
      raise "Bad config name: #{mode}" unless @bundle.config? mode

      @bundle.config(mode) do
        dest = @bundle.out || "#{@bundle.name}.js"
        puts "Building mode: #{@bundle.name}, config: '#{mode}', to '#{dest}'"

        built = []

        puts "* Including Runtime"
        built << File.read(OPAL_JS_PATH)

        puts "* Bundling:   #{@bundle.name}"
        build_bundle @bundle, mode


        parse_data = @parser.parse_data
        built << ";"
        built << @parser.build_parse_data(parse_data)

        puts "* Init"
        built << "opal.init();"

        built << @parser.wrap_with_runtime_helpers(@built_code.join)
        built << ";"

        if main = @bundle.main
          puts "* Main:       #{main}"
          built << "opal.main('#{main}', '#{@bundle.name}');"
        end

        File.open(dest, 'w+') { |o| o.write built.join }
      end
    end

    ##
    # Actually builds a bundle - returns a string.
    #
    # Standard build for a bundle.
    #
    #     opal.bundle({
    #       "name": "foo",
    #       "libs": { ... }
    #     });

    def build_bundle bundle, mode = :build
      bundle.config(mode) do
        if bundle.builder
          @built_code << (bundle.header.to_s + bundle.builder.call)
          return
        end

        libs  = bundle.lib_files
        files = bundle.other_files
        code  = []

        code << "opal.bundle({'name': '#{bundle.name}'"

        unless libs.empty?
          l = libs.map do |lib|
            src  = build_file File.join(bundle.root, lib)
            "'#{lib}':#{src}"
          end

          code << ",'libs':{#{l.join ','}}"
        end

        unless files.empty?
          f = files.map do |file|
            src  = build_file File.join(bundle.root, file)
            "'#{file}':#{src}"
          end

          code << ",'files':{#{f.join ','}}"
        end

        code << "});"

        @built_code << code.join
        @built_bundles << bundle.name

        bundle.stdlib.each { |std| build_stdlib std }
        bundle.dependencies.each { |dep| build_dependency dep }
      end
    end

    ##
    # Builds the given depdendency +dep+ if it hasnt already been built. If
    # it has been built (for this build), then just returns.

    def build_dependency dep
      raise DependencyNotInstalledError, dep.name unless dep.installed?
      bundle = dep.bundle
      name   = bundle.name

      return if @built_bundles.include? name

      puts "* Dependency: #{name}"
      build_bundle bundle
    end

    ##
    # Build the given +stdlib+ file if it hasn't been already added. Bundles
    # are responsible for listing the stdlib files they depend on.

    def build_stdlib stdlib
      return if @built_stdlib.include? stdlib

      @built_code << "opal.lib('#{stdlib}.rb', function(){});"
      @built_stdlib << stdlib
    end

    ##
    # Builds the given +file+. This may be a ruby or javascript file,
    # and anything else will cause an error.
    #
    # This will return the string that can be executed by opal in any
    # js environment.

    def build_file file
      raise "File does not exist '#{file}'" unless File.exists? file

      case File.extname file
      when '.rb'
        @parser.parse(File.read(file), file)[:code]
      when '.js'
        "function(VM, self, FILE) { #{File.read file} }"
      else
        raise "Bad file type for building '#{file}'"
      end
    end

  end
end

