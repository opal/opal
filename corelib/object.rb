# Core object in hierarchy. Most of the implementation of this core
# object are implemented in {Kernel}.
class Object
  def initialize (*a)
    # ...
  end

  def == (other)
    `self === other`
  end

  alias_method :equal?, :==

  def instance_eval (&block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `block(self)`
  end

  def instance_exec (*args, &block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `block.apply(null, [self].concat(args))`
  end


  def method_missing (sym, *args)
    raise NoMethodError, "undefined method `#{sym}` for #{self.inspect}"
  end

  def __send__ (name, *args, &block)
    `
      var method = self['m$' + name.toString()];

      return method.apply(null, [self].concat(args));
    `
  end

  alias_method :send, :__send__
end

