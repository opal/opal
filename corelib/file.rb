class File
  def self.expand_path(path, dir_string = undefined)
    `VM.opal.fs.expand_path(path, dir_string)`
  end

  def self.join(*paths)
    `VM.opal.fs.join.apply(VM.opal.fs, paths)`
  end

  def self.dirname(path)
    `VM.opal.fs.dirname(path)`
  end

  def self.extname(path)
    `VM.opal.fs.extname(path)`
  end

  def self.basename(path, suffix)
    `VM.opal.fs.basename(path, suffix)`
  end

  def self.exist?(path)
    `VM.opal.fs.exist_p(path)`
  end
end
