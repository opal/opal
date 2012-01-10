require 'opal/environment'

module Opal
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
      @environment  = Environment.load Dir.getwd
    end

    def build
      @verbose  = true
      @base     = File.expand_path(@options[:out] || '.')

      FileUtils.mkdir_p File.dirname(@base)

      if @options[:gems]
        Array(@options[:gems]).each do |g|
          if spec = @environment.find_spec(g)
            build_spec spec, false
            build_spec spec, true
          else
            puts "Cannot find gem dependency #{g}"
          end
        end
      end

      if @options[:stdlib]
        Array(@options[:stdlib]).each do |s|
          build_stdlib s, false
          build_stdlib s, true
        end
      end

      # Build opal by default unless explicitly set to 'false' in options
      unless @options[:opal] == false
        build_opal false
        build_opal true
      end
    end

    def build_spec(spec, debug = false)
      sources = spec.require_paths
      output  = output_for @base, spec.name, debug

      log_build spec.name, debug, output

      Dir.chdir(spec.full_gem_path) do
        Builder.new(sources, :join => output, :debug => debug).build
      end
    end

    def build_stdlib(stdlib, debug)
      path = File.join Opal.opal_dir, 'runtime', 'stdlib', "#{stdlib}.rb"
      out  = output_for @base, stdlib, debug

      if File.exist? path
        log_build stdlib, debug, out

        parser = Parser.new :debug => debug
        code   = parser.parse File.read(path), path

        File.open(out, 'w+') do |o|
          o.write "opal.lib('#{stdlib}', function() {\n#{code}\n});\n"
        end
      else
        puts "Cannot find stdlib dependency #{stdlib}"
      end
    end

    # Builds/copies the opal runtime into the :out directory.
    def build_opal(debug = false)
      out = output_for @base, 'opal', debug
      log_build 'opal', debug, out

      File.open(out, 'w+') { |o| o.write(debug ? Opal.runtime_debug_code : Opal.runtime_code) }
    end

    # Logs a file being built to stdout in verbose mode.
    #
    # @param [String] name a name identifying what was being built
    # @param [Boolean] debug a flag to indicate debug mode (or not)
    # @param [String] out the output location of the file
    def log_build(name, debug, out)
      puts "Building #{name}#{debug ? ' (debug)' : ''} to #{out}" if @verbose
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
