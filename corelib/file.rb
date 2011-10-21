class File
  def self.expand_path(path, dir_string = undefined)
    `Op.fs.expand_path(path, dir_string)`
  end

  def self.join(*paths)
    `Op.fs.join.apply(Op.fs, paths)`
  end

  def self.dirname(path)
    `Op.fs.dirname(path)`
  end

  def self.extname(path)
    `Op.fs.extname(path)`
  end

  def self.basename(path, suffix)
    `Op.fs.basename(path, suffix)`
  end

  def self.exist?(path)
    `Op.fs.exist_p(path)`
  end
end
