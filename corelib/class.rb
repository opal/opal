class Class < Module

  def self.new(sup = Object)
    `var res = rb_define_class_id('AnonClass', sup);

    if (sup.m$inherited) {
      sup.m$inherited(res);
    }

    return res;`
  end

  def allocate
    `return new self.$a();`
  end

  def new(*args)
    obj = allocate

    `if ($B.f == arguments.callee) {
      $B.f = obj.$m.initialize;
    }`

    obj.initialize *args
    obj
  end

  def inherited(cls)
    nil
  end

  def superclass
    `var sup = self.$s;

    if (!sup) {
      if (self == rb_cObject) return nil;
      throw new Error('RuntimeError: uninitialized class');
    }

    return sup;`
  end

  def native_prototype(proto)
    `rb_native_prototype(self, proto);`
    self
  end

  # Make the given object an instance of this class. This takes
  # an **existing** object and adds the correct class, method
  # table and id to the receiver.
  #
  # @param [NativeJSObject] obj
  # @return [instance]
  def from_native(obj)
    `return rb_obj_from_native(obj, self);`
  end
end

