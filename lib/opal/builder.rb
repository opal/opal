require 'fileutils'

module Opal
  class Builder
    extend Rake::DSL if defined?(Rake) and Rake.const_defined?(:DSL)

    def self.option(*syms)
      syms.each do |s|
        attr_accessor s
      end
    end

    option :name, :specs_dir

    def self.setup(&block)
      project = self.new Dir.getwd
      project.instance_eval &block

      desc "Build specs"
      task :spec do
        project.build_spec
      end

      project
    end

    def initialize(root_dir = Dir.getwd)
      @root_dir    = root_dir
      @build_dir   = 'build'
      @specs_dir   = 'spec'
      @name        = File.basename root_dir

      @verbose     = true
      @parser      = Parser.new
    end

    def log(str)
      puts str if @verbose
    end

    def build_spec
      spec_dir = File.expand_path @specs_dir
      out_name = "#{name}.spec.js"
      out_file = File.join @build_dir, out_name

      log "Building specs to #{out_file}"

      FileUtils.mkdir_p @build_dir
      File.open(out_file, 'w+') do |o|
        Dir["#{spec_dir}/**/*.rb"].each do |spec|
          o.puts build_file spec
        end
      end
    end

    def build_file(path)
      @parser.parse File.read(path), path
    end
  end
end