class User
  def initialize(name)
    @name = name
  end

  def authenticated?
    if admin? or special_permission?
      true
    else
      raise "not authenticated"
    end
  end

  def admin?
    @name == 'Bob'
  end

  def special_permission?
    false
  end
end
