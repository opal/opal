# backtick_javascript: true

class ::NilClass
  %x{
    var proto = self.$$prototype;
    proto.$$meta = #{self};
    proto.$$id = Opal.nil_id;
    proto.call = proto.apply = function() { Opal.raise(Opal.LocalJumpError, 'no block given'); };
    proto.$$frozen = true;
    proto.$$comparable = true;
  }

  class << self
    def allocate
      ::Kernel.raise ::TypeError, "allocator undefined for #{name}"
    end

    undef :new
  end

  def !
    true
  end

  def &(other)
    false
  end

  def |(other)
    `other !== false && other !== nil`
  end

  def ^(other)
    `other !== false && other !== nil`
  end

  def ==(other)
    `other === nil`
  end

  def dup
    nil
  end

  def clone(freeze: true)
    nil
  end

  def inspect
    'nil'
  end

  def nil?
    true
  end

  def singleton_class
    ::NilClass
  end

  def to_a
    []
  end

  def to_h
    `new Map()`
  end

  def to_i
    0
  end

  def to_s
    ''
  end

  def to_c
    ::Complex.new(0, 0)
  end

  def rationalize(*args)
    ::Kernel.raise ::ArgumentError if args.length > 1
    ::Kernel.Rational(0, 1)
  end

  def to_r
    ::Kernel.Rational(0, 1)
  end

  def instance_variables
    []
  end

  alias to_f to_i
end
