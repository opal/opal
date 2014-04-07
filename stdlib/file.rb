class File
  SEPARATOR = '/'

  def self.expand_path(path, basedir = nil)
    expand_regexp = %r{(/|^)[^/]+/\.\./}
    full_path = [basedir || '.', path].join(SEPARATOR)
    full_path = full_path.gsub(expand_regexp, '\1') while full_path =~ expand_regexp
    full_path
  end
end
