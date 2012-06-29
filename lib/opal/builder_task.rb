require 'opal/builder'

module Opal
  class BuilderTask
    include Rake::DSL if defined? Rake::DSL

    attr_accessor :name, :build_dir, :specs_dir, :files, :dependencies

    def initialize(namespace = nil)
      @project_dir = Dir.getwd

      @name         = 'app'
      @build_dir    = 'build'
      @specs_dir    = 'spec'
      @files        = Dir['lib/**/*.{rb,js}']
      @dependencies = []
      @debug_mode   = false

      yield self if block_given?

      define_tasks
    end

    def build_gem(name, debug)
      spec = Gem::Specification.find_by_name name
      code = Builder.build :files => spec.require_paths, :dir => spec.full_gem_path

      write_code code, File.join(@build_dir, "#{name}.js")
    rescue Gem::LoadError => e
      verbose "  - Error: Could not find gem #{name}"
    end

    def write_code(code, out)
      verbose " * #{ out }"
      File.open(out, 'w+') { |o| o.puts code }
    end

    def define_tasks
      desc "Build opal project"
      task :build do
        code = Builder.build :files => @files
        write_code code, File.join(@build_dir, "#{@name}.js")
      end

      desc "Build specs"
      task :spec do
        code = Builder.build :files => @specs_dir
        write_code code, File.join(@build_dir, "#{@name}.specs.js")
      end

      desc "Build dependencies"
      task :dependencies do
        write_code Opal.runtime, File.join(@build_dir, 'opal.js')
        @dependencies.each { |dep| build_gem dep, @debug_mode }
      end

      desc "Show build config"
      task :config do
        { :name => @name, :build_dir => @build_dir, :specs_dir => @specs_dir,
          :files => @files, :dependencies => @dependencies
        }.each { |k, v| puts "#{ k }: #{ v.inspect }" }
      end
    end

    # Print message if in verbose mode
    def verbose(msg)
      puts msg
    end
  end
end