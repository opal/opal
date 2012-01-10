class BasicObject
  def initialize(*)
  end

  def ==(other)
    `this === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var meth = this[mid_to_jsid(symbol)] || $opal.mm(mid_to_jsid(symbol));

      return meth.apply(this, args);
    }
  end

  alias send __send__
  
  alias eql? ==
  alias equal? ==

  def instance_eval(string = nil, &block)
    %x{
      if (block === nil) {
        raise(RubyArgError, 'block not supplied');
      }

      return block.call(this, this);
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        raise(RubyArgError, 'block not supplied');
      }

      return block.apply(this, args);
    }
  end

  def method_missing(symbol, *args)
    `raise(RubyNoMethodError, 'undefined method \`' + symbol + '\` for ' + #{inspect})`
  end

  def singleton_method_added(symbol)
  end

  def singleton_method_removed(symbol)
  end

  def singleton_method_undefined(symbol)
  end
end
