# BasicObject is the root object in opal. Even {Object} inherits from
# {BasicObject}. Instances of BasicObject (or subclasses of) are useful
# as they give almost a clean interface in which the absolute minimum of
# methods are defined on it. It therefore becomes useful for such
# applications as HashStructs.
class BasicObject

  def initialize(*a)
    # ...
  end

  def ==(other)
    `if (self == other) return Qtrue;
    return Qfalse;`
  end

  def equal?(other)
    self == other
  end

  def __send__(method_id, *args, &block)
    `args.unshift(self);
    var method = self.$m[#{method_id.to_s}];


    if ($B.f == arguments.callee) {
      $B.f = method;
    }

    return method.apply(self, args);`
  end

  def instance_eval(&block)
    raise ArgumentError, "block not supplied" unless block_given?
    `block(self);`
    self
  end

  def method_missing(sym, *args)
    `console.log("self's class' class id: " + self.$klass.__classid__);`
    `console.log("super's cassid: " + self.$super.__classid__);`
    raise NoMethodError, "undefined method `#{sym}` for #{self.inspect}"
  end
end

