require 'opal'
require 'opal/parser'
require 'fileutils'

module Opal
  class Builder
    attr_reader :configs

    ##
    # Initialize the build class with the application root given
    # by `root'.
    #
    # @param [String] root application root.

    def initialize root = Dir.getwd
      @root     = root
      @base     = File.basename @root

      @config   = :build
      @configs  = {}
      @default  = :build

      @parser   = Parser.new

      config(:build) { yield self } if block_given?
    end

    def config name = :build, &block
      return @config unless block_given?

      old     = @config
      config  = name.to_sym
      @config = @configs[config] ||= {}
      yield

      @config = old 
    end

    def self.config_accessor name
      define_method name do
        @config[name] || @configs[:build][name]
      end

      define_method "#{name}=" do |val|
        @config[name] = val
      end
    end

    config_accessor :out

    config_accessor :files

    config_accessor :main

    config_accessor :gemfile_group

    config_accessor :stdlib

    def reset
      @built_bundles = [] # array of bundle names already built (Strings)
      @built_stdlib  = [] # array of stdlib names already built
      @built_code    = [] # array of strings to be used in output
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

      path = File.join OPAL_DIR, 'stdlib', "#{stdlib}.rb"
      code = @parser.parse File.read(path), path

      @built_code << "opal.lib('#{stdlib}.rb', #{code});"
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
        @parser.parse(File.read(file), file)
      when '.js'
        "function(self, FILE) { #{File.read file} }"
      else
        raise "Bad file type for building '#{file}'"
      end
    end

  end
end

