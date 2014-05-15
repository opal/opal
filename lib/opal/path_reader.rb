require 'opal/hike_path_finder'

module Opal
  class PathReader
    def initialize(file_finder = HikePathFinder.new)
      @file_finder = file_finder
    end

    def read(path)
      full_path = file_finder.find(path)
      return nil if full_path.nil?
      File.read(full_path)
    end


    private

    attr_reader :file_finder
  end
end
