class Array
  def self.inherited(klass)
    replace = Class.new(Array::Wrapper)

    %x{
      klass._proto        = replace._proto;
      klass._proto._klass = klass;
      klass._alloc        = replace._alloc;
      klass.__parent      = #{Array::Wrapper};

      klass.$allocate = replace.$allocate;
      klass.$new      = replace.$new;
      klass["$[]"]    = replace["$[]"];
    }
  end
end

class Array::Wrapper
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

      if (result._isArray) {
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

      if (result._isArray && (index._isRange || length !== undefined)) {
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
