require 'rails'

module Opal
  module Rails
    class Engine < ::Rails::Engine
      config.app_generators.javascript_engine :opal
    end
  end
end
