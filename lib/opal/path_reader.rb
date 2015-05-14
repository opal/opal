require 'opal/hike_path_finder'

module Opal
  class PathReader
    def initialize(file_finder = HikePathFinder.new)
      @file_finder = file_finder
    end

    def read(path)
      full_path = expand(path)
      return nil if full_path.nil?
      File.open(full_path, 'rb:UTF-8'){|f| f.read}
    end

    def expand(path)
      if Pathname.new(path).absolute? || path =~ %r{\A.?.#{File::SEPARATOR}}
        path
      else
        file_finder.find(path)
      end
    end

    def paths
      file_finder.paths
    end


    private

    attr_reader :file_finder
  end
end
