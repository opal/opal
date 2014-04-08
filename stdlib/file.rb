class File
  SEPARATOR = '/'

  def self.expand_path(path, basedir = nil)
    path = [basedir, path].compact.join(SEPARATOR)
    parts = path.split(SEPARATOR)
    new_parts = []
    parts.each do |part|
      if part == '..'
        new_parts.pop
      else
        new_parts << part
      end
    end
    new_parts.join(SEPARATOR)
  end
end
