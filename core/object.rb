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
end
