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

  def parameters
    `#{@method}.$$parameters`
  end

  def source_location
    `#{@method}.$$source_location` || ['(eval)', 0]
  end

  def comments
    `#{@method}.$$comments` || []
  end

  def call(*args, &block)
    %x{
      #@method.$$p = block;

      return #@method.apply(#@receiver, args);
    }
  end

  alias [] call

  def unbind
    UnboundMethod.new(@owner, @method, @name)
  end

  def to_proc
    %x{
      var proc = self.$call.bind(self);
      proc.$$unbound = #@method;
      proc.$$is_lambda = true;
      return proc;
    }
  end

  def inspect
    "#<Method: #{@receiver.class}##@name>"
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

  def parameters
    `#{@method}.$$parameters`
  end

  def source_location
    `#{@method}.$$source_location` || ['(eval)', 0]
  end

  def comments
    `#{@method}.$$comments` || []
  end

  def bind(object)
    # TODO: re-enable when Module#< is fixed
    # unless object.class <= @owner
    #   raise TypeError, "can't bind singleton method to a different class"
    # end
    Method.new(object, @method, @name)
  end

  def inspect
    "#<UnboundMethod: #{@owner.name}##@name>"
  end
end
