class Method
  attr_reader :owner, :receiver, :name

  def initialize(receiver, method, name)
    @receiver = receiver
    @owner    = receiver.class
    @name     = name
    @method   = method
  end

  def arity
    @method.arity
  end

  def call(*args, &block)
    %x{
      #@method._p = block;

      return #@method.apply(#@object, args);
    }
  end

  alias [] call

  def unbind
    UnboundMethod.new(@owner, @method, @name)
  end

  def to_proc
    @method
  end

  def inspect
    "#<Method: #{@obj.class.name}##@name}>"
  end
end

class UnboundMethod
  attr_reader :owner, :name

  def initialize(owner, method, name)
    @owner  = owner
    @method = method
    @name   = name
  end

  def arity
    @method.arity
  end

  def bind(object)
    Method.new(object, @method, @name)
  end

  def inspect
    "#<UnboundMethod: #{@owner.name}##@name>"
  end
end
