require 'hike'

module Opal
  class HikePathFinder < Hike::Trail
    def initialize(paths = Opal.paths)
      super()
      append_paths *paths
      append_extensions '.js', '.js.rb', '.rb'
    end
  end
end
