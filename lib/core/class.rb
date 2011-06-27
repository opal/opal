class Class < Module

  def allocate
    `return new self.allocator();`
  end

  # This needs to support forwaring blocks to .initialize
  #
  # if ($runtime.P.f == arguments.callee) {
  #  $runtime.P.f = obj.$m.initialize
  # }
  #
  def new(*args)
    obj = allocate

    `if ($B.f == arguments.callee) {
      $B.f = obj.m$initialize;
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

