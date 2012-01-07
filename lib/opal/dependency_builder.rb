require 'opal/environment'

module Opal
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
      @environment  = Environment.load Dir.getwd
    end

    def build
      @verbose  = @options[:verbose]
      @base     = File.expand_path(@options[:out] || '.')
      @parser   = Parser.new

      FileUtils.mkdir_p File.dirname(@base)

      if @options[:gems]
        Array(@options[:gems]).each do |g|
          if spec = @environment.specs.find { |s| s.name == g }
            build_spec spec
          else
            puts "Cannot find gem dependency #{g}"
          end
        end
      end

      if @options[:stdlib]
        Array(@options[:stdlib]).each do |s|
          build_stdlib s
        end
      end

      if @options[:opal]
        build_opal
      end
    end

    def build_spec(spec)
      fname   = "#{spec.name}.js"
      sources = spec.require_paths
      output  = File.join @base, fname

      puts "Building #{spec.name} to #{output}" if @verbose

      Dir.chdir(spec.full_gem_path) do
        Builder.new(sources, :join => output).build
      end
    end

    def build_stdlib(stdlib)
      path  = File.join Opal.opal_dir, 'runtime', 'stdlib', "#{stdlib}.rb"
      out   = File.join @base, "#{stdlib}.js"

      if File.exist? path
        puts "Building #{stdlib} to #{out}" if @verbose

        code = @parser.parse File.read(path), path

        File.open(out, 'w+') do |o|
          o.write "opal.lib('#{stdlib}', function() {\n#{code}\n});\n"
        end
      else
        puts "Cannot find stdlib dependency #{stdlib}"
      end
    end

    # Builds/copies the opal runtime into the :out directory.
    def build_opal
      out = File.join @base, 'opal.js'
      puts "Building opal to #{out}" if @verbose

      File.open(out, 'w+') { |o| o.write Opal.runtime_code }
    end
  end
end
