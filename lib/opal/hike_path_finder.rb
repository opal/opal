require 'hike'

module Opal
  class HikePathFinder < Hike::Trail
    def initialize(root)
      super
      append_path '.'
      append_extension '.js'
      append_extension '.js.rb'
      append_extension '.rb'
    end
  end
end
