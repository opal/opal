require 'opal'
require 'opal/parser'
require 'fileutils'

module Opal
  class Builder
    attr_reader :configs
    attr_reader :name

    def initialize
      @default  = :default
      @config   = @default
      @configs  = {
        :default => {
          :debug        => false,
          :runtime      => false,
          :dependencies => false
        },
        :debug => {
          :debug        => true,
          :runtime      => false,
          :dependencies => false
        },
        :test => {
          :debug        => true,
          :runtime      => true,
          :dependencies => true
        }
      }

      @environment = Environment.new(File.basename Dir.getwd)

      config(@default) { yield self } if block_given?
    end

    def config name = @default, &block
      return @config unless block_given?

      old     = @config
      config  = name.to_sym
      @config = @configs[config] ||= {}
      yield

      @config = old 
    end
    
    def config? name
      @configs.key? name
    end

    def self.config_accessor name
      define_method name do
        @config[name] || @configs[@default][name]
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

    config_accessor :debug

    config_accessor :runtime

    config_accessor :dependencies

    def reset
      @built_bundles = [] # array of bundle names already built (Strings)
      @built_stdlib  = [] # array of stdlib names already built
      @built_code    = [] # array of strings to be used in output
      @parser        = Parser.new :debug => self.debug
    end

    def destination_for mode
      return self.out if self.out
      out = @environment.name
      out += ".#{mode}" unless mode == @default
      "#{out}.js"
    end

    ##
    # Actually build this.

    def build mode = @default
      raise "Bad config name: #{mode}" unless config? mode

      config mode do
        reset
        dest = destination_for mode
        puts "Building: '#{@environment.name}', config: '#{mode}', to '#{dest}'"

        built = []

        if self.runtime
          puts "* Including Runtime"
          built << File.read(OPAL_JS_PATH)
        end

        @environment.files = self.files #if self.files
        build_gem @environment
        
        if self.dependencies
          specs_for(mode).each do |spec|
            build_gem spec
          end
        end
        
        (self.stdlib || []).each { |std| build_stdlib std }
        
        built << @parser.wrap_with_runtime_helpers(@built_code.join)
        built << ";"

        if main = self.main
          puts "* Main:     #{main}"
          built << "opal.main('#{main}', '#{@environment.name}');"
        end

        File.open(dest, 'w+') { |o| o.write built.join "\n" }
      end
    end
    
    ##
    # All dependencies for given mode. If mode is not @default, then
    # all @default dependencies will also be returned
    
    def specs_for mode = @default
      deps = @environment.specs_for mode
      deps += @environment.specs_for @default unless mode == @default
      deps
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

    def build_gem spec
      return if @built_bundles.include? spec.name
      @built_bundles << spec.name
      
      puts "* Bundling: #{spec.name}"
      libs  = spec.lib_files
      files = spec.respond_to?(:other_files) ? spec.other_files : []
      code  = []
      root = spec.full_gem_path
      
      code << "opal.gem({'name': '#{spec.name}'"

      unless libs.empty?
        l = libs.map do |lib|
          src  = build_file File.join(root, lib)
          "'#{lib}':#{src}"
        end

        code << ",'libs':{#{l.join ','}}"
      end

      unless files.empty?
        f = files.map do |file|
          src  = build_file File.join(root, file)
          "'#{file}':#{src}"
        end

        code << ",'files':{#{f.join ','}}"
      end

      code << "});"

      @built_code << code.join
      @built_bundles << name      
    end

    ##
    # Build the given +stdlib+ file if it hasn't been already added. Bundles
    # are responsible for listing the stdlib files they depend on.

    def build_stdlib stdlib
      return if @built_stdlib.include? stdlib

      path = File.join OPAL_DIR, 'runtime', 'stdlib', "#{stdlib}.rb"
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
  end # Builder
end
