class Object
  # Kernel included inside runtime.js

  # FIXME
  def methods
    []
  end

  # FIXME
  def singleton_methods
    []
  end

  # hack to make bridged classes get basicobject methods
  alias __send__ __send__
  alias send send
end