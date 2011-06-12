module Opal

  # The gem class wraps around RubyGem's Gem::Specification class to basically add
  # support for building a gem ready for the browser. The actual gem object can be
  # accessed through {#spec}.
  class Gem

    # The real Gem::Specification object, which is used for accessing gem info
    attr_reader :spec

    # Root directory for the package
    attr_reader :root_dir

    def initialize(rootdir)
      require 'rubygems'
      @root_dir = rootdir
      path = File.expand_path File.join(@root_dir, File.basename(@root_dir) + '.gemspec')

      # we MUST chdir here to make sure files globs etc in the gemspec use the basedir
      # as the working directory, otherwise opal, or the main gem working dir will
      # accidentally be the cwd.
      Dir.chdir(File.dirname(path)) do
        @spec = ::Gem::Specification.load path
      end

      raise "Bad/missing gemspec in #{rootdir}" unless @spec
    end

    def name
      @spec.name
    end

    def version
      @spec.version.to_s
    end

    def require_paths
      @spec.require_paths
    end

    def files
      @spec.files
    end

    def test_files
      @spec.test_files
    end

    def to_s
      "#<Gem '#{name}'>"
    end

    # Returns an array of dependencies for this package. Version requirements
    # are ignored for now. This simply returns the array of package names that
    # are needed. If the package.json does not declare any, then an empty
    # array is returned.
    #
    # @return {Array<String>}
    def dependencies
      dependencies = @spec.dependencies

      dependencies.map { |d| d.name }
    end

    # Returns the files from the .files property of the gem that are only
    # available from the require_paths array. Basically, these are the files
    # that are our 'lib' files. They are returned as relative to the root.
    #
    # @return [Array<String>]
    def lib_files
      paths = require_paths
      ext = %w[.rb .js] 

      files.select do |f|
        f.start_with?(*paths) && ext.include?(File.extname(f)) 
      end
    end
  end
end

