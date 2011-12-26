module Opal
  ##
  # Default Environment that assumes no Gemfile or gemspec for the given
  # app/library.

  class Environment
    def self.load(dir)
      return GemfileEnvironment.new dir if File.exists? File.join(dir, 'Gemfile')
      return GemspecEnvironment.new dir unless Dir["#{dir}/*.gemspec"].empty?
      return Environment.new dir
    end

    attr_accessor :files
    attr_reader :root

    def initialize(root)
      @root = root
    end

    def name
      File.basename @root
    end

    ##
    # Method to stay compatible with gems - just returns this app/gem root.
    def full_gem_path
      @root
    end

    ##
    # Default require paths is just 'lib'
    def require_paths
      ['lib']
    end

    ##
    # All lib files.
    def lib_files
      Dir["lib/**/*.rb"]
    end

    def specs
      []
    end
  end

  ##
  # Used for libs/gems that have a gemspec (but no Gemfile!).
  class GemspecEnvironment < Environment; end

  ##
  # Used for environments which use a Gemfile

  class GemfileEnvironment < Environment
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
    def specs_for(group)
      deps = bundler.dependencies_for group
      bundler.specs.select do |spec|
        deps.find { |dep| dep.name == spec.name && dep.name =~ /^opal\-/ }
      end
    end

    def specs
      bundler.specs.select do |spec|
        spec.name =~ /^opal\-/
      end
    end
  end
end
