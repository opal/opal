# frozen_string_literal: true

require 'opal/regexp_anchors'
require 'opal/hike'

module Opal
  class PathReader
    RELATIVE_PATH_REGEXP = /#{Opal::REGEXP_START}\.?\.#{Regexp.quote File::SEPARATOR}/.freeze
    DEFAULT_EXTENSIONS = ['.js', '.js.rb', '.rb', '.opalerb'].freeze

    def initialize(paths = Opal.paths, extensions = DEFAULT_EXTENSIONS)
      @file_finder = Hike::Trail.new
      @file_finder.append_paths(*paths)
      @file_finder.append_extensions(*extensions)
    end

    def read(path)
      full_path = expand(path)
      return nil if full_path.nil?
      File.open(full_path, 'rb:UTF-8', &:read) if File.exist?(full_path)
    end

    def expand(path)
      if Pathname.new(path).absolute? || path =~ RELATIVE_PATH_REGEXP
        path
      else
        find_path(path)
      end
    end

    def paths
      file_finder.paths
    end

    def extensions
      file_finder.extensions
    end

    def append_paths(*paths)
      # Opal.append_paths(*paths) # this actually fixed a bug once
      file_finder.append_paths(*paths)
    end

    private

    def find_path(path)
      pathname = Pathname(path)
      return path if pathname.absolute? && pathname.exist?
      file_finder.find(path)
    end

    attr_reader :file_finder
  end
end
