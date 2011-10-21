class Dir
  def self.getwd
    `Op.fs.cwd`
  end

  def self.pwd
    `Op.fs.cwd`
  end

  def self.[](*args)
    `Op.fs.glob.apply(Op.fs, args)`
  end
end

