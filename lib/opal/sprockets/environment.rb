require 'sprockets'
require 'opal/sprockets/processor'
require 'opal/sprockets/erb'

module Opal
  # @deprecated
  def self.process asset
    Environment.new[asset].to_s
  end

  # @deprecated
  class Environment < ::Sprockets::Environment
    def initialize *args
      warn "WARNING: Opal::Sprockets::Environment is deprecated. "\
           "Please use Opal::Server directly or append Opal.paths to the environment manually."
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
