require 'opal'
require 'sprockets'

module Opal
  class Environment < Sprockets::Environment
    def initialize(*)
      super
      
      Opal.paths.each { |path| append_path path }
    end
  end
end
