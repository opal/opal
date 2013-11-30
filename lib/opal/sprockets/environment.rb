require 'sprockets'

module Opal
  # Environment is a subclass of Sprockets::Environment which already has our opal
  # load paths loaded. This makes it easy for stand-alone rack apps, or test runners
  # that have opal load paths ready to use. You can also add an existing gem's lib
  # directory to our load path to use real gems inside your opal environment.
  #
  # If you are running rails, then you just need opal-rails instead, which will
  # do this for you.
  class Environment < ::Sprockets::Environment
    def initialize *args
      super
      Opal.paths.each { |p| append_path p }
    end

    def use_gem gem_name
      append_path File.join(Gem::Specification.find_by_name(gem_name).gem_dir, 'lib')
    end
  end
end
