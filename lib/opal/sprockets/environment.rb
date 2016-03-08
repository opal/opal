require 'sprockets'
require 'opal/sprockets/processor'
require 'opal/sprockets/erb'

module Opal
  class Environment < ::Sprockets::Environment
    def initialize *args
      super
      append_opal_paths
    end

    def use_gem gem_name
      Opal.use_gem gem_name
      append_opal_paths
    end

    private

    def append_opal_paths
      Opal.paths.each { |p| append_path p }
    end
  end
end
