require 'rake'
require 'rake/tasklib'
require 'opal/bundle'
require 'opal/builder'

module Opal
  class BundleTask
    include Rake::DSL if defined? Rake::DSL # keep < 0.9.2 happy

    def initialize task_name = :opal, &block
      @task_name = task_name
      @builder   = Builder.new
      @bundle    = @builder.bundle

      @bundle.config(:normal) { yield @bundle } if block_given?

      define
    end

    def define
      # :normal will just be mapped to :task_name
      configs = @bundle.configs.keys - [:normal]

      configs.each { |config| define_config config }

      default = @bundle.default

      if default == :normal
        desc "Builds default Opalfile config: normal."
        task @task_name => ["#{@task_name}:normal"]
        define_config :normal
      else
        desc "Builds default Opalfile config: #{@bundle.default}"
        task @task_name => ["#{@task_name}:#{@bundle.default}"]
      end

      desc "Install dependencies for bundle"
      task "#{@task_name}:install" do
        @bundle.install
      end
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

