require 'fileutils'

module Opal
  class BuilderTask
    include Rake::DSL if defined? Rake::DSL

    def initialize(namespace = nil)
      @builder = Builder.new
      yield @builder if block_given?

      define_tasks
    end

    def define_tasks
      define_task :"opal:build", "Build project" do
        puts "BUILD"
      end

      define_task :"opal:spec", "Build specs" do
        puts "SPEC"
      end

      define_task :"opal:config", "Show config" do
        @builder.to_config.each do |key, val|
          puts "#{key}: #{val.inspect}"
        end
      end
    end

    def define_task(name, desc, &block)
      desc desc
      task name, &block
    end
  end

  class Builder
    attr_accessor :name, :build_dir, :specs_dir

    def initialize
      @project_dir = Dir.getwd

      self.build_dir = 'build'
      self.specs_dir = 'spec'
      self.files     = Dir['./lib/**/*.rb']
    end

    def build_dir=(dir)
      @build_dir = File.join @project_dir, dir
    end

    def specs_dir=(dir)
      @specs_dir = File.join @project_dir, dir
    end

    def files=(files)
      @files = files
    end

    def to_config
      {
        :build_dir => @build_dir,
        :specs_dir => @specs_dir,
        :files     => @files
      }
    end
  end
end