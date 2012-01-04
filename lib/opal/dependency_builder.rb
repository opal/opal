require 'opal/environment'

module Opal
  class DependencyBuilder

    def initialize(options = {})
      @options      = options
      @environment  = Environment.load Dir.getwd
    end

    def build
      specs   = @environment.specs
      base    = File.expand_path(@options[:out] || '.')
      version = Opal::VERSION

      specs.each do |spec|
        fname   = "#{spec.name}-#{spec.version}.js"
        sources = spec.require_paths
        output  = File.join base, fname

        Dir.chdir(spec.full_gem_path) do
          Compiler.new(sources, :join => output).compile
        end
      end

      File.open(File.join(base, "opal-#{version}.js"), 'w+') do |o|
        o.write Opal.build_runtime
      end

      File.open(File.join(base, "opal-#{version}.debug.js"), 'w+') do |o|
        o.write Opal.build_runtime true
      end
    end
  end
end
