
class Dir

  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.getwd
    `return Op.fs.cwd;`
  end

  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.pwd
    `return Op.fs.cwd;`
  end

  def self.[](*a)
    `return Op.fs.glob.apply(Op.fs, a);`
  end
end

