# use_strict: true
# frozen_string_literal: true

class Method
  attr_reader :owner, :receiver, :name

  def initialize(receiver, owner, method, name)
    @receiver = receiver
    @owner    = owner
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
      #{@method}.$$p = block;

      return #{@method}.apply(#{@receiver}, args);
    }
  end

  alias [] call

  def >>(other)
    @method >> other
  end

  def <<(other)
    @method << other
  end

  def unbind
    UnboundMethod.new(@receiver.class, @owner, @method, @name)
  end

  def to_proc
    %x{
      var proc = self.$call.bind(self);
      proc.$$unbound = #{@method};
      proc.$$is_lambda = true;
      proc.$$arity = #{@method}.$$arity;
      proc.$$parameters = #{@method}.$$parameters;
      return proc;
    }
  end

  def inspect
    "#<#{self.class}: #{@receiver.class}##{@name} (defined in #{@owner} in #{source_location.join(':')})>"
  end
end

class UnboundMethod
  attr_reader :source, :owner, :name

  def initialize(source, owner, method, name)
    @source = source
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
    %x{
      if (#{@owner}.$$is_module || Opal.is_a(#{object}, #{@owner})) {
        return #{Method.new(object, @owner, @method, @name)};
      }
      else {
        #{raise TypeError, "can't bind singleton method to a different class (expected #{object}.kind_of?(#{@owner} to be true)"};
      }
    }
  end

  def inspect
    "#<#{self.class}: #{@source}##{@name} (defined in #{@owner} in #{source_location.join(':')})>"
  end
end
