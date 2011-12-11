module Opal
  class Environment
    def initialize root = Dir.getwd
      @root = root
    end

    def bundler
      return @bundler if @bundler
      require 'bundler'
      @bundler = Bundler.load
    end

    def dependencies
      bundler.dependencies
    end

    def specifications
      bundler.specs
    end
  end
end
