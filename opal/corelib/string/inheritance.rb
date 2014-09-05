class String
  def self.inherited(klass)
    replace = Class.new(String::Wrapper)

    %x{
      klass.$$proto        = replace.$$proto;
      klass.$$proto.$$class = klass;
      klass.$$alloc        = replace.$$alloc;
      klass.$$parent      = #{String::Wrapper};

      klass.$allocate = replace.$allocate;
      klass.$new      = replace.$new;
    }
  end
end

class String::Wrapper
  def self.allocate(string = "")
    obj = super()
    `obj.literal = string`
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

  def initialize(string = '')
    @literal = string
  end

  def method_missing(*args, &block)
    result = @literal.__send__(*args, &block)

    if `result.$$is_string != null`
      if `result == #@literal`
        self
      else
        self.class.allocate(result)
      end
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

  alias eql? ==
  alias === ==

  def to_s
    @literal
  end

  def to_str
    self
  end

  def inspect
    @literal.inspect
  end
end
