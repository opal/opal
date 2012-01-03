class BasicObject
  def initialize(*)
  end

  def ==(other)
    `this === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var meth = this[mid_to_jsid(symbol)];

      if (meth) {
        args.unshift(null);

        return meth.apply(this, args);
      }
      else {
        throw new Error("method missing yielder for " + symbol + " in __send__");
      }
    }
  end

  alias_method :send, :__send__

  alias_method :eql?, :==
  alias_method :equal?, :==

  def instance_eval(string = nil, &block)
    %x{
      if (block === nil) {
        raise(RubyArgError, 'block not supplied');
      }

      return block.call(this, null, this);
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        raise(RubyArgError, 'block not supplied');
      }

      args.unshift(null);

      return block.apply(this, args);
    }
  end

  def method_missing(symbol, *args)
    `raise(RubyNoMethodError, 'undefined method \`' + symbol + '\` for ' + #{inspect})`
  end

  def singleton_method_added(symbol)
    nil
  end

  def singleton_method_removed(symbol)
    nil
  end

  def singleton_method_undefined(symbol)
    nil
  end
end
