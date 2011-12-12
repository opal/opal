module Opal
  class Environment
    attr_accessor :files
    attr_reader :name
    
    def initialize name
      @name = name
    end

    def files_to_build
      self.files || Dir['lib/**/*.rb']
    end
    
    def lib_files
      files_to_build.select { |f| f.start_with? 'lib/' }
    end
    
    def other_files
      files_to_build.reject { |f| f.start_with? 'lib/' }
    end
    
    def full_gem_path
      Dir.getwd
    end
    
    def bundler
      return @bundler if @bundler
      require 'bundler'
      @bundler = Bundler.load
    end
    
    ##
    # Specs for specific group. Top level is :default
    def specs_for group
      deps = bundler.dependencies_for group
      bundler.specs.select do |spec|
        deps.find { |dep| dep.name == spec.name && dep.name =~ /^opal\-/ }
      end
    end
    
    ##
    # All opal specs
    def specs
      bundler.specs.select do |spec|
        spec.name =~ /^opal\-/
      end
    end
  end # Environment
end