class File
  SEPARATOR = '/'

  def self.expand_path(path, basedir = nil)
    [basedir || '.', path].join(SEPARATOR).gsub(%r{/[^/]+/\.\./}, '/')
  end
end
