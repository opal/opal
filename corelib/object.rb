class Object
  include Kernel

  def methods
    `self.$k.$methods`
  end

  alias_method :private_methods, :methods

  alias_method :protected_methods, :methods

  alias_method :public_methods, :methods

  def singleton_methods
    raise NotImplementedError, 'Object#singleton_methods not yet implemented'
  end
end
