class Module
  def native_module
    `Opal.global[#{self.name}] = #{self}`
  end
end

class Class
  def native_alias(jsid, mid)
    `#{self}._proto[#{jsid}] = #{self}._proto['$' + #{mid}]`
  end

  alias native_class native_module
end
