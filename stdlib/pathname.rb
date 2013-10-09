class Pathname
  def initialize path
    raise ArgumentError if path == "\0"
    @path = path
  end

  attr_reader :path

  def == other
    other.path == @path
  end

  def absolute?
    @path.start_with? '/'
  end

  def relative?
    !absolute?
  end

  def to_path
    @path
  end
  alias :to_str :to_path
  alias :to_s :to_path
end

module Kernel
  def Pathname(path)
  end
end
