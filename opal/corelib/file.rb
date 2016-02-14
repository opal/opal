class File < IO
  Separator = SEPARATOR = '/'
  ALT_SEPARATOR = nil
  PATH_SEPARATOR = ':'

  class << self
    def expand_path(path, basedir = nil)
      path = [basedir, path].compact.join(SEPARATOR)
      parts = path.split(SEPARATOR)
      new_parts = []
      parts[0] = Dir.home if parts.first == '~'
      parts[0] = Dir.pwd if parts.first == '.'

      parts.each do |part|
        if part == '..'
          new_parts.pop
        else
          new_parts << part
        end
      end
      new_parts.join(SEPARATOR)
    end
    alias realpath expand_path

    def dirname(path)
      split(path)[0..-2].join(SEPARATOR)
    end

    def basename(path)
      split(path)[-1]
    end

    def extname(path)
      raise TypeError, 'no implicit conversion of nil into String' if path.nil?
      path = path.to_path if path.respond_to?(:to_path)
      raise TypeError, "no implicit conversion of #{path.class} into String" unless path.is_a?(String)
      filename = basename(path)
      return '' if filename.nil?
      last_dot_idx = filename[1..-1].rindex('.')
      # extension name must contains at least one character .(something)
      (last_dot_idx.nil? || last_dot_idx + 1 == filename.length - 1) ? '' : filename[(last_dot_idx + 1)..-1]
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
