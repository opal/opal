require 'fileutils'
require 'opal/git_dependency'

module Opal
  # The path inside an app/bundle dir, where opal should install and
  # find dependencies. Defaults to 'vendor/opal'
  VENDOR_PATH = File.join 'vendor', 'opal'

  # Raised when an Opalfile cannot be loaded.
  class OpalfileDoesNotExistError < Exception; end

  # Raised when an Opalfile contains duplicate dependencies.
  class OpalfileDuplicateDependencyError < Exception; end

  # Raised when trying to build a dependency that is not installed
  class DependencyNotInstalledError < Exception; end

  # A Bundle is a gem or directory with code in it.
  class Bundle
    # Valid keys that can be used with [#set]
    VALID_SET_KEYS = %w[name out files main runtime header builder default]

    def self.load root = Dir.getwd
      path = File.join root, 'Opalfile'
      return self.new unless File.exist? path

      bundle = Dir.chdir(root) { eval File.read(path), binding, path }
      raise "Result of Opalfile is not a Bundle" unless Bundle === bundle

      bundle
    end

    def self.config_accessor name
      define_method name do
        @config[name] || @configs[:normal][name]
      end

      define_method "#{name}=" do |val|
        @config[name] = val
      end
    end

    attr_reader :root

    attr_accessor :name

    attr_accessor :default

    config_accessor :out

    config_accessor :header

    config_accessor :runtime

    config_accessor :files

    config_accessor :main

    config_accessor :stdlib

    ##
    # Returns the builder for the current config if no block given,
    # otherwise sets the block for the current config.

    def builder &block
      @config[:builder] = block if block

      return @config[:builder]
    end

    def initialize root = Dir.getwd
      @root    = root
      @name    = File.basename root
      @configs = {}
      @config  = :normal

      # set defaults etc
      config :normal do
        self.stdlib = []

        yield self if block_given?
      end
    end

    def config name = :normal, &block
      return @config unless block_given?

      old = @config
      config = name.to_sym
      @config = @configs[config] ||= {}
      yield
      @config = old
    end

    def configs
      @configs
    end

    # Returns true/false if the given config name is valid and
    # present
    def config? name
      @configs.key? name
    end

    def gem name, opts = {}
      raise "name should be a String" unless String === name
      raise "Options should be a Hash" unless Hash === opts

      if opts[:git]
        register_git_dependency name, opts
      else
        register_dependency name, opts
      end
    end

    ##
    # Returns an array of lib files to use. These will be relative.

    def lib_files
      libs = files_to_build.select { |f| /^lib\// =~ f }
      libs
    end

    ##
    # Returns an array of "other files" to include. These will be
    # everything not inside "lib"

    def other_files
      other = files_to_build.reject { |f| /^lib\// =~ f }
      other
    end

    ##
    # Returns the files to build. This will look at the config :files
    # property first, and if files have not been manually set, then
    # just returns a default (which will be all ruby files in 'lib/'.

    def files_to_build
      self.files || Dir.chdir(@root) { Dir['lib/**/*.rb'] }
    end

    def dependencies
      deps = @config[:dependencies]
      # FIXME: should also check from normal mode..
      deps ? deps.values : []
    end

    def register_dependency(name, opts)
      raise "Registering normal gem dependencies not yet supported"
    end

    def register_git_dependency(name, opts)
      deps = (@config[:dependencies] ||= {})
      raise OpalfileDuplicateDependencyError if deps[name]
      path = File.join @root, VENDOR_PATH, name

      dep = GitDependency.new name, opts[:git], path
      deps[name] = dep
    end

    public

    def install
      path = File.join @root, VENDOR_PATH

      @configs.each do |name, config|
        deps = config[:dependencies]

        deps.each do |name, dep|
          if dep.installed?
            puts "Skipping `#{name}'"
          else
            puts "Installing `#{name}'"
            dep.install
          end
        end if deps
      end
    end
  end
end

