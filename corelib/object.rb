# Core object in hierarchy. Most of the implementation of this core
# object are implemented in {Kernel}.
class Object

  def initialize(*a)
    # ...
  end

  def ==(other)
    `return self === other;`
  end

  def equal?(other)
    self == other
  end

  def __send__(method_id, *args, &block)
    `var method = self['m$' + method_id];

    if ($B.f == arguments.callee) {
      $B.f = method;
    }

    return method.apply(self, args);`
  end

  def instance_eval(&block)
    raise ArgumentError, "block not supplied" unless block_given?
    `block.call(self);`
    self
  end

  def method_missing(sym, *args)
    raise NoMethodError, "undefined method `#{sym}` for #{self.inspect}"
  end
end

