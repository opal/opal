class Proc
  `def._isProc = true`
  `def.is_lambda = false`

  def self.new(&block)
    unless block
      raise ArgumentError, "tried to create a Proc object without a block"
    end

    block
  end

  def call(*args, &block)
    %x{
      if (block !== nil) {
        self._p = block;
      }

      var result;

      if (self.is_lambda) {
        result = self.apply(null, args);
      }
      else {
        result = Opal.$yieldX(self, args);
      }

      if (result === $breaker) {
        return $breaker.$v;
      }

      return result;
    }
  end

  alias [] call

  def to_proc
    self
  end

  def lambda?
    # This method should tell the user if the proc tricks are unavailable,
    # (see Proc#lambda? on ruby docs to find out more).
    `!!self.is_lambda`
  end

  def arity
    `#{self}.length`
  end

  def to_n
    self
  end
end

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
