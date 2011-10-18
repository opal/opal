class BasicObject
  def initialize(*args)
    # nothing ...
  end

  def ==(other)
    `self === other`
  end

  def __send__(symbol, *args, &block)
    `self['m$' + symbol.toString()].apply(null, [self, symbol].concat(args))`
  end

  alias_method :eql?, :==
  alias_method :equal?, :==

  def instance_eval(string = nil, &block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `block(self, null)`
  end

  def instance_exec(*args, &block)
    raise ArgumentError, 'block not supplied' unless block_given?

    `block.apply(null, [self, null].concat(args))`
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
