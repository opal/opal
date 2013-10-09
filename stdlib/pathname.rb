class Pathname
  def initialize path
    raise ArgumentError if path == "\0"
    @path = path
  end

  attr_reader :path

  def == other
    other.path == @path
  end
end

module Kernel
  def Pathname(path)
  end
end
