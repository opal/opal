class BasicObject
  def initialize(*)
  end

  def ==(other)
    `self === other`
  end

  def __id__
    `self._id || (self._id = Opal.uid())`
  end

  def __send__(symbol, *args, &block)
    %x{
      var func = self['$' + symbol]

      if (func) {
        if (block !== nil) {
          func._p = block;
        }

        return func.apply(self, args);
      }

      if (block !== nil) {
        self.$method_missing._p = block;
      }

      return self.$method_missing.apply(self, [symbol].concat(args));
    }
  end

  def !
    false
  end

  alias eql? ==
  alias equal? ==

  def instance_eval(&block)
    Kernel.raise ArgumentError, "no block given" unless block

    %x{
      var block_self = block._s,
          result;

      block._s = null;
      result = block.call(self, self);
      block._s = block_self;

      return result;
    }
  end

  def instance_exec(*args, &block)
    Kernel.raise ArgumentError, "no block given" unless block

    %x{
      var block_self = block._s,
          result;

      block._s = null;
      result = block.apply(self, args);
      block._s = block_self;

      return result;
    }
  end

  def method_missing(symbol, *args, &block)
    Kernel.raise NoMethodError, "undefined method `#{symbol}' for BasicObject instance"
  end
end
