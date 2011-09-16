require 'yaml'

module RBP

  class Package

    attr_reader :root

    def initialize(root = Dir.getwd)
      @root = root
      __load_yml
    end

    def __load_yml
      yml_path = File.join @root, 'package.yml'

      unless File.exists? yml_path
        raise "Missing package.yml in `#{@root}'"
      end

      @yml = YAML.load File.read(yml_path)

      raise "Bad package.yml" unless @yml and @yml['name'] and @yml['version']
    end

    # Returns an array of lib files relative to the root of
    # this package
    def lib_files
      libs = nil

      Dir.chdir(File.join @root, 'lib') do
        libs = Dir['**/*.rb']
      end

      libs
    end

    # package name
    def name
      @yml['name']
    end

    # package version
    def version
      @yml['version']
    end
  end
end

