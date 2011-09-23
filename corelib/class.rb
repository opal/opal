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

  # This will wrap the given `obj` by an instance of this class. A new
  # instance is created and a `@_native` instance variable set with the
  # given obj. No additional properties are added to obj as this may
  # cause problems with garbage collection etc.
  #
  # The returned object will not have `#initialize` called, or indeed
  # `.allocate` called as all the work is done internally.
  #
  # @param [NativeObject] obj object to wrap
  # @return [Object] new instance of this class
  def from_native(obj)
    `var inst = new self.$a();
    inst._native = obj;
    return inst;`
  end
end

