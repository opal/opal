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
      if Pathname.new(path).absolute?
        path
      elsif path =~ %r{\A\.?\.#{File::SEPARATOR}}
        file_finder.find_relative_current_dir(path)
      else
        file_finder.find(path)
      end
    end

    def paths
      file_finder.paths
    end

    def append_paths(*paths)
      file_finder.append_paths(*paths)
    end

    private

    attr_reader :file_finder
  end
end
