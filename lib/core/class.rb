class Class < Module

  def allocate
    `return new $rb.RObject(self);`
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
    `var sup = self.$super;

    if (!sup) {
      if (self == $rb.BasicObject) return nil;
      throw new Error('RuntimeError: uninitialized class');
    }

    return sup;`
  end

end

