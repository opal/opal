class Dir
  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.getwd
    `Op.fs.cwd`
  end

  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.pwd
    `Op.fs.cwd`
  end

  def self.[] (*args)
    `Op.fs.glob.apply(Op.fs, args)`
  end
end

