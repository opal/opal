class NativeObject
  # Will return a new instance with either a passed in native object, or
  # created with a new empty js object which we can add values to.
  def initialize(obj = `{}`)
    @native = obj
  end

  def [](key)
    `return key in self.native ? self.native[key] : nil;`
  end

  def []=(key, val)
    `return self.native[key] = val;`
  end

  def to_hash
    hash = {}
    obj  = @native

    %x[for (var k in obj) {
      if (obj.hasOwnProperty(k)) {]
        hash[`k`] = `obj[k]`
      %x[}
    }]

    hash
  end
end

