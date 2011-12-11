require 'rake'
require 'rake/tasklib'
require 'opal/bundle'
require 'opal/builder'

module Opal
  class BundleTask
    include Rake::DSL if defined? Rake::DSL # keep < 0.9.2 happy

    def initialize task_name = :opal, &block
      @task_name = task_name
      @builder   = Builder.new &block

      define
    end

    def define
      configs = @builder.configs.keys
      configs.each { |config| define_config config }
    end

    def define_config name
      desc "Build '#{name}' opal configuration."
      task "#{@task_name}:#{name}" do
        begin
          @builder.build name
        rescue DependencyNotInstalledError => e
          abort "Dependency '#{e}' not installed. Run 'opal install' first."
        end
      end
    end

  end # class BundleTask
end # module Opal

