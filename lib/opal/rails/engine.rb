require 'rails'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal

      # Cache eager_load_paths now, otherwise the assets dir is added
      # and its .rb files are eagerly loaded.
      config.eager_load_paths

      initializer 'opal.asset_paths', :after => 'sprockets.environment', :group => :all do |app|
        app.config.before_initialize do
          app.config.eager_load_paths = app.config.eager_load_paths.dup - Dir["#{app.root}/app/{assets,views}"]
        end

        Opal.paths.each do |path|
          app.assets.append_path path
        end
      end

    end
  end
end
