require 'opal/builder'

module Opal
  class BuilderTask
    include Rake::DSL if defined? Rake::DSL

    attr_accessor :name, :build_dir, :specs_dir, :files, :dependencies

    def initialize(namespace = nil)
      @project_dir = Dir.getwd

      @build_dir    = './build'
      @specs_dir    = './spec'
      @files        = Dir['./lib/**/*.rb']
      @dependencies = []

      yield self if block_given?

      define_tasks
    end

    def to_config
      {
        :build_dir    => @build_dir,
        :specs_dir    => @specs_dir,
        :files        => @files,
        :dependencies => @dependencies
      }
    end

    def build_gem(name)
      spec = Gem::Specification.find_by_name name
      out  = File.expand_path(File.join @build_dir, "#{name}.js")

      Dir.chdir(spec.full_gem_path) do
        build_files name, spec.require_paths, out
      end
    rescue Gem::LoadError => e
      puts "  - Error: Could not find gem #{name}"
    end

    def build_files(name, files, out)
      puts "* building #{name}"
      Builder.new(:files => files, :out => out).build
    end

    def define_tasks
      define_task :"opal:build", "Build project" do
        puts "BUILD"
      end

      define_task :"opal:spec", "Build specs" do
        build_files "./specs", @specs_dir, "#{name}.specs.js"
      end

      define_task :"opal:dependencies", "Build dependencies" do
        puts "* runtime => #{File.join @build_dir, 'opal.js'}"
        @dependencies.each { |dep| build_gem dep }
      end

      define_task :"opal:config", "Show config" do
        to_config.each do |key, val|
          puts "#{key}: #{val.inspect}"
        end
      end
    end

    def define_task(name, desc, &block)
      desc desc
      task name, &block
    end
  end
end