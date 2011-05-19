module Opal
  class FileSystem

    def initialize(opal, context)
      @opal = opal
      @ctx = context
    end

    def cwd
      Dir.getwd
    end

    def glob(*arr)
      Dir.glob(arr)
    end

    def exist_p(path)
      File.exist? path
    end

    def expand_path(filename, dir_string = nil)
      File.expand_path filename, dir_string
    end

    def dirname(file)
      File.dirname file
    end

    def join(*parts)
      File.join *parts
    end
  end
end

