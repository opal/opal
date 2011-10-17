class BasicObject
  ##
  # Equality - At the +Object+ level, +==+ returns +true+ only if +obj+ and
  # +other+ are the same object.

  def == other
    `self === other`
  end

  alias_method :equal?, :==
  alias_method :eql?, :==

  def __send__ symbol, *args
    `var method = self['m$' + symbol.toString()];
    return method.apply(null, [self, symbol].concat(args));`
  end

  ##
  # Returns a new +BasicObject+

  def initialize *args
    # nothing ...
  end

  ##
  # Evaluates a string containing Ruby source code, or the given block,
  # within the context of the receiver (obj).

  def instance_eval string = nil, &block
    raise ArgumentError, 'block not supplied' unless block_given?
    `block(self, null)`
  end

  ##
  # Executes the given block within the context of the receiver. Also
  # passes in all given args as block args.

  def instance_exec *args, &block
    raise ArgumentError, 'block not supplied' unless block_given?
    `block.apply(null, [self, null].concat(args))`
  end

  ##
  # Invoked by Ruby when the receiver is sent a message it cannot handle.

  def method_missing symbol, *args
    raise NoMethodError, "undefined method `#{symbol}` for #{self.inspect}"
  end

  ##
  # Invoked as a callback whenever a singleton method is added to the
  # receiver.

  def singleton_method_added symbol
    # nothing ...
  end

  ##
  # Invoked as a callback whenever a singleton method is removed from the
  # receiver.

  def singleton_method_removed symbol
    # nothing ...
  end

  ##
  # Invoked as a callback whenever a singleton method is undefined in the
  # receiver.

  def singleton_method_undefined symbol
    # nothing ...
  end
end

