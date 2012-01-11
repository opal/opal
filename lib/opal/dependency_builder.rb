require 'opal/environment'

module Opal
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
    end

    def build
      @environment  = Environment.load Dir.getwd
      @verbose      = true
      @base         = File.expand_path(@options[:out] || '.')

      FileUtils.mkdir_p @base

      calculate_dependencies(@options[:gems]).each do |g|
        if spec = @environment.find_spec(g)
          build_spec spec
        else
          puts "Cannot find gem dependency #{g}"
        end
      end

      # Build opal by default unless explicitly set to 'false' in options
      unless @options[:opal] == false
        build_opal
      end
    end

    # Gather a list of dependencies to build. These are taken from the
    # following order:
    #
    # 1. if rake task given a list, use those.
    # 2. Use dependnecies listed in Gemfile :opal group, if it exists
    # 3. Use all runtime dependnecies from local gemspec (if it exists)
    #
    # If none of these are applicable, no dependnecies will be built.
    #
    # @param [Array, String] gems gems passed to rake task
    # @return [Array<String>] an array of gem names to build
    def calculate_dependencies(gems)
      return Array(gems) if gems
      @environment.specs
    end

    def build_spec(spec)
      sources  = spec.require_paths
      output   = output_for @base, spec.name, false
      debugout = output_for @base, spec.name, true

      log_build spec.name, output

      Dir.chdir(spec.full_gem_path) do
        Builder.new(sources, :out => output, :debug => false).build
        Builder.new(sources, :out => debugout, :debug => true).build
      end
    end

    # Builds/copies the opal runtime into the :out directory.
    def build_opal
      output   = output_for @base, 'opal', false
      debugout = output_for @base, 'opal', true
      log_build 'opal', output

      normcode  = Opal.runtime_code
      debugcode = Opal.runtime_debug_code

      File.open(output, 'w+') { |o| o.write normcode }
      File.open(debugout, 'w+') { |o| o.write debugcode }
    end

    # Logs a file being built to stdout in verbose mode.
    #
    # @param [String] name a name identifying what was being built
    # @param [String] out the output location of the file
    def log_build(name, out)
      puts "Building #{name} to #{out}" if @verbose
    end

    # Returns the output filename for a build target with the given name
    # and base directory in the given debug mode (true/false).
    #
    # @example
    #     output_for('foo', 'opal', true)   # => foo/opal.debug.js
    #     output_for('foo', 'opal', false)  # => foo/opal.js
    #
    # @param [String] base the base directory being built to
    # @param [String] name a name identifying what is being built
    # @param [Boolean] debug whether in debug mode or not
    # @return [String] full filename to built to
    def output_for(base, name, debug)
      fname = debug ? "#{name}.debug.js" : "#{name}.js"
      File.join base, fname
    end
  end
end
