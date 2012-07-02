require 'rails'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal
      
      initializer 'opal.assets' do |app|
        %w[opal-spec opal-dom].each do |gem_name|
          spec = Gem::Specification.find_by_name gem_name
          spec.require_paths.each do |path|
            path = File.join(spec.full_gem_path, path)
            app.config.assets.paths << path
          end
        end
      end
    end
  end
end
