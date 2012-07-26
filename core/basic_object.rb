class BasicObject
  def initialize(*)
  end

  def ==(other)
    `#{self} === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      var meth = #{self}['$' + symbol];

      if (!meth) {
        return #{ method_missing symbol };
      }

      return meth.apply(#{self}, args);
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

      return block.call(#{self});
    }
  end

  def instance_exec(*args, &block)
    %x{
      if (block === nil) {
        no_block_given();
      }

      return block.apply(#{self}, args);
    }
  end

  def method_missing(symbol, *args)
    raise NoMethodError, "undefined method `#{symbol}` for #{inspect}"
  end
end