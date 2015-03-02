class Array
  def self.inherited(klass)
    replace = Class.new(Array::Wrapper)

    %x{
      klass.$$proto         = replace.$$proto;
      klass.$$proto.$$class = klass;
      klass.$$alloc         = replace.$$alloc;
      klass.$$parent        = #{Array::Wrapper};

      klass.$allocate = replace.$allocate;
      klass.$new      = replace.$new;
      klass["$[]"]    = replace["$[]"];
    }
  end
end

class Array::Wrapper
  `def.$$is_array = true`

  def self.allocate(array = [])
    obj = super()
    `obj.literal = array`
    obj
  end

  def self.new(*args, &block)
    obj = allocate
    obj.initialize(*args, &block)
    obj
  end

  def self.[](*objects)
    allocate(objects)
  end

  def initialize(*args, &block)
    @literal = Array.new(*args, &block)
  end

  def method_missing(*args, &block)
    result = @literal.__send__(*args, &block)

    if `result === #@literal`
      self
    else
      result
    end
  end

  def initialize_copy(other)
    @literal = `other.literal`.clone
  end

  def respond_to?(name, *)
    super || @literal.respond_to?(name)
  end

  def ==(other)
    @literal == other
  end

  def eql?(other)
    @literal.eql?(other)
  end

  def to_a
    @literal
  end

  def to_ary
    self
  end

  def inspect
    @literal.inspect
  end

  # wrapped results
  def *(other)
    %x{
      var result = #{@literal * other};

      if (result.$$is_array) {
        return #{self.class.allocate(`result`)}
      }
      else {
        return result;
      }
    }
  end

  def [](index, length = undefined)
    %x{
      var result = #{@literal.slice(index, length)};

      if (result.$$is_array && (index.$$is_range || length !== undefined)) {
        return #{self.class.allocate(`result`)}
      }
      else {
        return result;
      }
    }
  end

  alias slice []

  def uniq
    self.class.allocate(@literal.uniq)
  end

  def flatten(level = undefined)
    self.class.allocate(@literal.flatten(level))
  end
end
