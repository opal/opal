require 'opal/builder'

module Opal
  class BuilderTask
    include Rake::DSL if defined? Rake::DSL

    attr_accessor :name, :build_dir, :specs_dir, :files, :dependencies,
                  :main, :specs_main

    def initialize(namespace = nil)
      @project_dir = Dir.getwd

      @name         = 'app'
      @build_dir    = 'build'
      @specs_dir    = 'spec'
      @files        = Dir['lib/**/*.{rb,js}']
      @dependencies = []
      @debug_mode   = false
      @spec_main    = "spec/spec_helper"

      yield self if block_given?

      define_tasks
    end

    def to_config
      {
        :name         => @name,
        :build_dir    => @build_dir,
        :specs_dir    => @specs_dir,
        :files        => @files,
        :dependencies => @dependencies,
        :main         => @main,
        :specs_main   => @specs_main
      }
    end

    def build_gem(name, debug)
      spec = Gem::Specification.find_by_name name
      out  = File.join @build_dir, "#{name}#{debug ? '.debug' : ''}.js"
      build_files :files => spec.require_paths,
                  :out   => out,
                  :debug => debug,
                  :dir   => spec.full_gem_path
    rescue Gem::LoadError => e
      puts "  - Error: Could not find gem #{name}"
    end

    def build_files(opts)
      puts " * #{opts[:out]}"
      Builder.build opts
    end

    def define_tasks
      define_task :build, "Build Opal Project" do
        name = @debug_mode ? "#@name.debug.js" : "#@name.js"
        build_files :files => @files,
                    :out   => File.join(@build_dir, "#@name.js")
      end

      define_task :spec, "Build Specs" do
        name = @debug_mode ? "#@name.specs.debug.js" : "#@name.specs.js"
        build_files :files => @specs_dir,
                    :out   => File.join(@build_dir, name),
                    :main  => @specs_main,
                    :debug => @debug_mode
      end

      define_task :dependencies, "Build dependencies" do
        out = File.join @build_dir, 'opal.js'
        puts " * #{out}"
        File.open(out, 'w+') do |out|
          out.write Opal.runtime
        end

        @dependencies.each { |dep| build_gem dep, @debug_mode }
      end

      define_task :debug, "Build debug mode" do
        @debug_mode = true
        Rake::Task[:build].invoke
        Rake::Task[:dependencies].invoke
        Rake::Task[:spec].invoke
      end

      define_task :config, "Show Build Config" do
        to_config.each { |key, val| puts "#{key}: #{val.inspect}" }
      end
    end

    def define_task(name, desc, &block)
      desc desc
      task name, &block
    end
  end
end