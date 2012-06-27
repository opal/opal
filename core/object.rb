class Object
  include Kernel

  # FIXME
  def methods
    []
  end

  alias private_methods methods
  alias protected_methods methods
  alias public_methods methods

  # FIXME
  def singleton_methods
    []
  end

  # HACK: to make bridged classes inherit BasicObject methods too
  alias __send__ __send__
  alias send send
end