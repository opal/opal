class BasicObject
  def initialize(*)
  end

  def ==(other)
    `this === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var meth = this[mid_to_jsid(symbol)];

      if (!meth) {
        return #{ method_missing symbol };
      }

      return meth.apply(this, args);
    }
  end

  alias send __send__

  alias eql? ==
  alias equal? ==

  def instance_eval(string, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.call(this, this);
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.apply(this, args);
    }
  end

  def method_missing(symbol, *args)
    raise NoMethodError, "undefined method `#{symbol}` for #{inspect}"
  end
end