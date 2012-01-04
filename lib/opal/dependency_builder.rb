require 'opal/environment'

module Opal
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
      @environment  = Environment.load Dir.getwd
    end

    def build
      specs = @environment.specs
      base  = File.expand_path(@options[:out] || '.')

      specs.each do |spec|
        fname   = "#{spec.name}.js"
        sources = spec.require_paths
        output  = File.join base, fname

        Dir.chdir(spec.full_gem_path) do
          Compiler.new(sources, :join => output).compile
        end
      end

      File.open(File.join(base, 'opal.js'), 'w+') do |o|
        o.write Opal.build_runtime
      end

      File.open(File.join(base, 'opal.debug.js'), 'w+') do |o|
        o.write Opal.build_runtime true
      end
    end
  end
end
