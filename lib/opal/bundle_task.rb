require 'rake'
require 'rake/tasklib'
require 'opal/bundle'

module Opal
  class Bundle
    # The output file this bundle should build to. This is optional, but
    # the bundle task will default it to "$name-$version.js".
    #
    # @return [String] path to build to
    attr_accessor :out
  end

  # Builds Rake tasks that automatically bundle an app/gem.
  #
  # Usage:
  #
  #     # in Rakefile
  #     require "opal/bundle_task"
  #
  #     Opal::BundleTask.new do |t|
  #       t.name    = "my_app"
  #       t.version = "0.0.1"
  #     end
  #
  # Running `rake bundle` will then bundle this application into
  # "$name-$version.js". The destination can be set using #out= on
  # [Bundle].
  #
  # An actual bundle instance is passed to the block as `t`, so see
  # [Bundle] for more options.
  class BundleTask
    def initialize(task_name = :bundle)
      @task_name = task_name
      @bundle = Bundle.new

      yield @bundle if block_given?
      define
    end

    def define
      desc "Bundle this package ready for a web browser"
      task(@task_name) do
        name = @bundle.name || File.basename(File.dirname)
        version = @bundle.version

        path = name
        path += "-#{version}" if version

        File.open("#{path}.js", "w+") { |o| o.write @bundle.build }
      end
    end
  end
end

