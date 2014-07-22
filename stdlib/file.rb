class File < IO
  Separator = SEPARATOR = '/'

  class << self
    def expand_path(path, basedir = nil)
      path = [basedir, path].compact.join(SEPARATOR)
      parts = path.split(SEPARATOR)
      new_parts = []
      parts[0] = Dir.home if parts.first == '~'

      parts.each do |part|
        if part == '..'
          new_parts.pop
        else
          new_parts << part
        end
      end
      new_parts.join(SEPARATOR)
    end

    def dirname(path)
      split(path)[-2]
    end

    def exist? path
      `Opal.modules[#{path}] != null`
    end
    alias exists? exist?

    def directory?(path)
      files = []
      %x{
        for (var key in Opal.modules) {
          #{files}.push(key)
        }
      }
      path = path.gsub(%r{(^.#{SEPARATOR}+|#{SEPARATOR}+$)})
      file = files.find do |file|
        file =~ /^#{path}/
      end
      file
    end

    def join(*paths)
      paths.join(SEPARATOR).gsub(%r{#{SEPARATOR}+}, SEPARATOR)
    end

    def split(path)
      path.split(SEPARATOR)
    end
  end
end
