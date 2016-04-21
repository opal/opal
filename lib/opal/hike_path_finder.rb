require 'hike'
require 'pathname'

module Opal
  class HikePathFinder < Hike::Trail
    def initialize(paths = Opal.paths)
      super()
      append_paths(*paths)
      append_extensions '.js', '.js.rb', '.rb', '.opalerb'
    end

    def find path, options={}
      pathname = Pathname(path)
      return path if pathname.absolute? and pathname.exist?
      super
    end

    def find_relative_current_dir path
      current_dir_index.find path
    end

    private

    def current_dir_index
      @current_dir_index ||= begin
        Hike::Index.new(Dir.pwd, [Dir.pwd], extensions, aliases)
      end
    end
  end
end
