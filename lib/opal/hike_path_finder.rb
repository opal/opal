require 'hike'
require 'pathname'

module Opal
  class HikePathFinder < Hike::Trail
    def initialize(paths = Opal.paths)
      super()
      append_paths(*paths)
      append_extensions '.js', '.js.rb', '.rb', '.opalerb'
    end

    def find path
      pathname = Pathname(path)
      return path if pathname.absolute? and pathname.exist?
      super
    end
  end
end
