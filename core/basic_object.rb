class BasicObject
  def initialize(*)
  end

  def ==(other)
    `#{self} === other`
  end

  def __send__(symbol, *args, &block)
    %x{
      return #{self}['$' + symbol].apply(#{self}, args);
    }
  end

  alias send __send__

  alias eql? ==
  alias equal? ==

  def instance_eval(string=undefined, &block)
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
end