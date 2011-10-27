class Class < Module
  def self.new(sup = Object, &block)
    `
      var klass = VM.define_class_id('AnonClass', sup);

      if (sup.$m.inherited) {
        sup.$m.inherited(sup, 'inherited', klass);
      }

      if (block) {
        block(klass, null);
      }

      return klass;
    `
  end

  def self.typeof (value)
    `typeof(value)`
  end

  def allocate
    `new VM.RObject(self)`
  end

  def new(*args, &block)
    obj = allocate
    obj.initialize *args, &block

    obj
  end

  def inherited(klass)
    nil
  end

  def superclass
    `
      var sup = self.$super;

      if (!sup) {
        if (self == rb_cBasicObject) {
          return null;
        }

        #{raise RuntimeError, 'uninitialized class'};
      }

      return sup;
    `
  end

  # Returns the given +object+, adding the needed properties to make it a
  # true instance of the receiver opal class. This means that the given
  # native object will act just like a regular instance of the receiver,
  # and will therefore respond to all the methods defined on it.
  #
  #     a = Object.from_native(`console`)     # => #<Object:0x93882>
  #     a.class     # => Object
  #
  def from_native(object)
    `VM.from_native(self, object)`
  end
end

