class BasicObject
  def initialize(*)
  end

  def ==(other)
    `this === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var meth = this[mid_to_jsid(symbol)] || opal.mm(mid_to_jsid(symbol));
      args.unshift(block);

      return meth.apply(this, args);
    }
  end

  alias send __send__

  alias eql? ==
  alias equal? ==

  def instance_eval(string, &block)
    %x{
      if (block == null) {
        throw RubyArgError.$new('block not supplied');
      }

      return block.call(this, null, this);
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block == null) {
        throw RubyArgError.$new('block not supplied');
      }

      return block.apply(this, args);
    }
  end

  def method_missing(symbol, *args)
    `throw RubyNoMethodError.$new(null, 'undefined method \`' + symbol + '\` for ' + #{inspect});`

    self
  end

  def singleton_method_added(symbol)
  end

  def singleton_method_removed(symbol)
  end

  def singleton_method_undefined(symbol)
  end
end
