require 'sprockets'
require 'opal/sprockets/processor'
require 'opal/sprockets/erb'

module Opal
  # Proccess using Sprockets
  #
  #   Opal.process('opal-jquery')   # => String
  def self.process asset
    Environment.new[asset].to_s
  end

  # Environment is a subclass of Sprockets::Environment which already has our opal
  # load paths loaded. This makes it easy for stand-alone rack apps, or test runners
  # that have opal load paths ready to use. You can also add an existing gem's lib
  # directory to our load path to use real gems inside your opal environment.
  #
  # If you are running rails, then you just need opal-rails instead, which will
  # do this for you.
  class Environment < ::Sprockets::Environment
    def initialize *args
      warn "Opal::Sprockets::Environment is deprecated. "\
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
