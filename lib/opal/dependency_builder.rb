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
        puts "building opal"
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
      sources = spec.require_paths
      output  = File.expand_path("#{spec.name}.js", @options[:out] || '.')
      puts "output is: #{output}"

      Dir.chdir(spec.full_gem_path) do
        Builder.new(:files => sources, :out => output).build
      end
    end

    # Builds/copies the opal runtime into the :out directory.
    def build_opal
      return
      output   = output_for @base, 'opal', false
      debugout = output_for @base, 'opal', true
      log_build 'opal', output

      normcode  = Opal.runtime_code
      debugcode = Opal.runtime_debug_code

      File.open(output, 'w+') { |o| o.write normcode }
      File.open(debugout, 'w+') { |o| o.write debugcode }
    end
  end
end
