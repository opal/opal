class Object
  include Kernel

  # FIXME
  def methods
    []
  end

  alias_method :private_methods, :methods

  alias_method :protected_methods, :methods

  alias_method :public_methods, :methods

  # FIXME
  def singleton_methods
    []
  end

  def to_native
    raise TypeError, 'no specialized #to_native has been implemented'
  end
end
