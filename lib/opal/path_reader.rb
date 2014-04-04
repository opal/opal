module Opal
  class PathReader
    def initialize(file_finder)
      @file_finder = file_finder
    end

    def read(path)
      File.read(file_finder.find(path))
    end


    private

    attr_reader :file_finder
  end
end
