
module Opal
  # Custom loader class, which an instance is set on the opal.loader property
  # to allow for disk based loading and access to modules/packages/gems.
  #
  # For now, this simply adds hard-coded paths to the load path. In future,
  # dynamic package lookup will take place, but for now we just manually loop
  # through gems/packages in this gems' dir, and the cwd dir (in ./vendor/) and
  # add each of their lib/ dirs). Unil we add a custom package manager, this
  # will make it the easiest way of managing packages for vienna.
  class Loader

    # Load paths. This is an array of all load paths
    attr_reader :paths

    # The vienna instance for the object
    attr_reader :vienna

    # @param vienna The js vienna object itself so we can talk to it
    # @param {Vienna::Context} context The v8 context
    def initialize(vienna, context)
      @vienna = vienna
      @ctx = context
      @paths = []

      # core lib/std lib
      @paths << File.expand_path(File.join('..', '..', '..', '..', 'lib'), __FILE__)

      hardcode_gems
    end

    # Register all gems - this is currently hardcoded while we don't have a
    # proper package manager. This needs to be replaced to be more dynamic in
    # lookup.
    def hardcode_gems
      return nil
      core = File.expand_path(File.join(__FILE__, '..', '..', '..', '..', 'gems'))

      Dir.open(core).each do |entry|
        try_dir = File.join core, entry
        if File.directory?(try_dir) && !['.', '..'].include?(entry)
          add_hardcoded_gem try_dir
        end
      end
    end

    # Add an individual hardcoded gem by its path. We need to check it has a
    # .gemspec in its dir, then add its lib directory to our path.
    def add_hardcoded_gem(path)
      # make sure gem dir has a gemspec
      gemspec = File.join path, File.basename(path) + '.gemspec'
      return unless File.exists? gemspec
      # make sure gem dir has a lib dir
      libpath = File.join path, 'lib'
      return unless File.exists? libpath
      # all is ok, so add to loadpath
      @paths << libpath
    end

    # Valid extensions. This should be more dynamic for custom extensions
    def valid_extensions
      %w[.rb .js]
    end

    # Exposed as replacement method.
    def resolve_lib(id)
      resolved = find_lib id, @paths
      raise "Cannot find lib '#{id}'" unless resolved
      resolved
    end

    # Resolve the id requested with the given valid paths
    def find_lib(id, paths)
      extensions = valid_extensions

      @paths.each do |path|

        extensions.each do |ext|
          candidate = File.join(path, id + ext)

          # if file exists, return it!
          return candidate if File.exists? candidate
        end

        # if has extension already
        candidate = File.join(path, id)
        return candidate if File.exists? candidate
      end

      # alternatively, if id is a full path, just load it
      if File.exist? id
        return File.expand_path id
      end

      if File.exist? id + '.rb'
        return File.expand_path(id + '.rb')
      end

      # if we cannot find it, just return nil
      nil
    end

    # Returns the contents of the module. This, in ruby, reads from the disk,
    # but the browser uses either XHR or a cached module reference. The
    # method name is kept generic to reflect this.
    #
    # @param {String} filename The filename to load. This is a full filename,
    # not just a module id.
    def file_contents(filename)
      File.read filename
    end

    # Special version of module contents that will compile the given ruby code
    # at the file into javascript first, before returning it. This is exposed
    # to vienna so that it makes it easier to compile and run ruby from the
    # v8 context. The default implementation of this throws an error to say
    # that in browser ruby code cannot be run.
    def ruby_file_contents(filename)
      parser = Opal::RubyParser.new File.read(filename)
      result = parser.parse!.generate_top
      result
    end

    # Wraps the content with the given filename. Basically, here we eval
    # the code inside a function which takes our exports, module,
    # require etc, and returns the function ready for calling. If an
    # error occures (likely a parse error) it is just thrown as normal
    def wrap(content, filename)
      code = "(function($rb, self, __FILE__) { #{content} });"
      # puts code
      @ctx.eval code, filename
    end
  end
end

