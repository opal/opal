class Class < Module

  def allocate
    `return new VM.RObject(self, VM.T_OBJECT);`
  end

  # This needs to support forwaring blocks to .initialize
  #
  # if (VM.P.f == arguments.callee) {
  #  VM.P.f = obj.$m.initialize
  # }
  #
  def new(*args)
    obj = allocate

    `if ($block.f == arguments.callee) {
      $block.f = obj.$m.initialize;
    }`

    obj.initialize *args
    obj
  end

  def superclass
    `var sup = self.$super;

    if (!sup) {
      if (self == VM.BasicObject) return nil;
      throw new Error('RuntimeError: uninitialized class');
    }

    return sup;`
  end

  # Use the receiver class as a wrapper around the given native
  # prototype. This should be the actual prototype itself rather than
  # the constructor function. For example, the core Array class may use
  # this like so:
  #
  #     class Array
  #       native_prototype `Array.prototype`
  #     end
  #
  # @return [Class] Returns the receiver
  def native_prototype(prototype)
    `return VM.native_prototype(prototype, self);`
  end
end

