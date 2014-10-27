class Pathname
  def initialize(path)
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

  def root?
    @path == '/'
  end

  def parent
    new_path = @path.sub(%r{/([^/]+/?$)}, '')
    new_path = absolute? ? '/' : '.' if new_path == ''
    Pathname.new(new_path)
  end

  def sub(*args)
    Pathname.new(@path.sub(*args))
  end

  def cleanpath
    `return $opal.normalize_loadable_path(#@path)`
  end

  def to_path
    @path
  end

  def hash
    @path
  end

  alias :to_str :to_path
  alias :to_s :to_path
end

module Kernel
  def Pathname(path)
    Pathname.new(path)
  end
end
