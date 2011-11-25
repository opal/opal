class BasicObject
  def initialize(*args)
    # nothing ...
  end

  def ==(other)
    `self === other`
  end

  def __send__(symbol, *args, &block)
    `
      var meth = self.$m[STR_TO_ID_TBL[symbol]];

      if (meth) {
        args.unshift(self);
        return meth.apply(null, args);
      }
      else {
        throw new Error("method missing yielder for " + symbol + " in __send__");
      }
    `
  end

  alias_method :eql?, :==
  alias_method :equal?, :==

  def instance_eval(string = nil, &block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `return block(self);`
  end

  def instance_exec(*args, &block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `
      args.unshift(self);
      return block.apply(null, args);
    `
  end

  def method_missing(symbol, *args)
    raise NoMethodError, "undefined method `#{symbol}` for #{self.inspect}"
  end

  def singleton_method_added(symbol)
    # nothing ...
  end

  def singleton_method_removed(symbol)
    # nothing ...
  end

  def singleton_method_undefined(symbol)
    # nothing ...
  end
end
