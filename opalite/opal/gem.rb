
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

    # Given the dependency name (required by this package), resolve its
    # location on disk, or nil if it cannot be found. For now this will only
    # check the built in locations, but in future it should search within the
    # package first etc.
    #
    # @param {String} dep The name of the dependency
    # @return {String, nil} Path to package if found
    def find_dependency(dep)
      search_dir = File.expand_path File.join(__FILE__, '..', '..', '..', 'gems')
      # FIXME we should not rely on dirname being same as package name. We should
      # really go throgh all search dirs in order, and check each directory in that,
      # and check its json file if it exists, then check the jsons name property
      package_dir = File.join search_dir, dep
      return nil unless File.exists? package_dir

      json_file = File.join package_dir, dep + '.gemspec'
      return nil unless File.exists? json_file

      package_dir
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

    # Returns the contents of the given file, relative to the root_dir,
    # wrapped ready for use in the browser. Javascript sources will simply
    # be wrapped in a function with its free variables, and ruby sources will
    # be compiled, then wrapped.
    #
    # @return {String}
    def wrap_source(path)
      full_path = File.expand_path File.join(root_dir, path)
      ext_name  = File.extname path

      content = case ext_name
      when '.js'
        source = File.read full_path
        "function($runtime, self, __FILE__) { #{source} }"

      when '.rb'
        source = Opal::RubyParser.new(File.read(full_path)).parse!.generate_top
        # compiled ruby is now javascript, so dont try and fool opal.js!
        path = path.sub(/\.rb/, '.js')
        "function($runtime, self, __FILE__) { #{source} }"

      else
        raise "Bad file type for wrapping. Must be ruby or javascript"
      end

      path.inspect + ": " + content
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

    # Returns a string that can be written to a file to be used with opal in
    # the browser.
    #
    # @return {String}
    def to_bundle(opts = {})
      # all files to build. default to just lib files
      files = lib_files
      files += test_files if opts[:test_files]

      bundle = []
      bundle << %[opal.register("#{self.name}", {]
      bundle << %[  "name": #{self.name.inspect},]
      bundle << %[  "version": #{self.version.inspect},]
      bundle << %[  "require_paths": #{self.require_paths.inspect},]
      bundle << %[  "files": {]
      bundle << %[    #{files.map { |f| wrap_source f }.join(",\n    ")}]
      bundle << %[  }]
      bundle << %[});]
    end

    # This will return a simple string. For now, resources etc are not
    # supported, and will be added back later. This simply calls
    # to_bundle on itself, and all of its dependencies..
    #
    # @return {String}
    def bundle(opts = {})
      b = Bundle.new(self, opts)
      b.build
    end
  end
end

