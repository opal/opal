module Opal

  # The Bundle class is used to bundle a package, and optionally all of its
  # dependencies and the base opal boot file into a js file ready for browser
  # deployment. It takes a package, and a set of options, and simply returns a
  # combined string of the built packages.
  #
  # This does not yet support building resources from the packages. Just the
  # basic package building works.
  #
  # The following options are supported:
  #
  # - `:dependencies` - An array of additional dependencies to add that may not
  # be listed in the .gemspec. This is used, for example, to include opalspec
  # into test builds so that opalspec does not need to be a dependency in all
  # build environments.
  # - `:main` - The file to run in the browser. An example may be
  # 'vienna/autorun'. Note this is not a bin file, and should be a simple lib
  # file that will be in the load path.
  # - `:bin` - Alternatively, a bin file listed within a gem that should be
  # included, and then run within the browser. An example would be
  # 'vienna/vienna', where the first part is the gem containing the bin file,
  # which is named the second part.
  # - `:standalone` - Exclude dependencies listed in the gemspec. This is false
  # by default so all listed dependencies will be recursively added to the
  # resulting file. If set to true, the gemspec dependencies will not be
  # included. This does not affect the `:dependencies` option, which are
  # included seperately to these dependencies.
  # - `:to` - Usually this process will just return a string, but by passing a
  # `:to` option, the result will be written to the file specified by the given
  # name. This only works for simple bundling where no resources are needed.
  #
  # - primary - basically which gem should we chdir into. default is the gem that
  # .bundle was called on (i.e. the main package)
  class Bundle

    # Ensure we keep a unique set of packages - we dont want duplications
    attr_reader :handled_packages

    # Queue of packages waiting to be built
    attr_reader :package_queue

    # The {Gem} instance to build with a set of optional options.
    #
    # @param [Gem] package The package to build
    # @param {Hash} opts Build options
    def initialize(package, opts = {})
      @package = package
      @options = opts

      @handled_packages = []
      @package_queue = []
    end

    # Actually build the bundle. Returns the result, for now, as a string.
    #
    # @return {String} bundled packages
    def build
      result = []
      pkg = nil
      builder = Builder.new

      @package_queue << @package
      @handled_packages << @package.name

      # unless @options[:standalone]
        # add_dependency('core', @package)
      # end

      if @options[:dependencies]
        deps = @options[:dependencies]
        deps = [deps] unless deps.is_a? Array
        deps.each { |dep| add_dependency dep, @package }
      end

      while pkg = @package_queue.pop
        puts pkg
        # if this is our initial package and we are standalone, make sure we
        # pass that option into build package
        if pkg == @package && @options[:standalone]
          puts "standalone #{pkg}"
          result << build_package(pkg, true)
        else
          result << build_package(pkg)
        end
      end

      unless @options[:standalone]
        result.unshift opal_boot_content
      end

      result << "opal.primary('#{@package.name}');" if @options[:primary]

      if @options[:main]
        result << "opal.require('#{@options[:main]}');"
      end

      if @options[:core]
        result.unshift builder.build_core
      end

      if @options[:to]
        File.open(@options[:to], 'w+') { |out| out.write result.join("\n") }
      end

      result.join "\n"
    end

    # Boot content for opal. This bootloader takes all the gems in the browser
    # context and manages them. Opal self-loads in the bootloader.
    #
    # @return [String]
    def opal_boot_content
      path = File.expand_path File.join(__FILE__, '..', '..', '..', 'gems', 'core', 'runtime.js')
      File.read path
    end

    # Builds a single package. This will build the package, discover its
    # dependencies, and then add them to the queue of packages to build. This
    # method will then return the built package as a string.
    #
    # @param {Package} package The package to build
    # @param {Boolean} standalone Whether to exclude gem dependencies.
    # @return {String} Built package
    def build_package(package, standalone = false)
      # Work through each dependency and work out if we need it
      unless standalone
        package.dependencies.each do |dep|
          add_dependency dep, package
        end
      end

      if package == @package
        # primary package - we add options here
        package.to_bundle @options
      else
        # sub package
        package.to_bundle
      end
    end

    def add_dependency(dep, package)

        unless @handled_packages.include? dep
          @handled_packages << dep

          loc = package.find_dependency(dep)
          raise "Cannot find dependency '#{dep}' for #{package}" unless loc

          pkg = Gem.new loc
          @package_queue << pkg
        end
    end

  end
end

