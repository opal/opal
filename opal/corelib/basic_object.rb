class BasicObject
  def initialize(*)
  end

  def ==(other)
    `self === other`
  end

  alias equal? ==

  def __id__
    `self.$$id || (self.$$id = Opal.uid())`
  end

  def __send__(symbol, *args, &block)
    %x{
      var func = self['$' + symbol]

      if (func) {
        if (block !== nil) {
          func.$$p = block;
        }

        return func.apply(self, args);
      }

      if (block !== nil) {
        self.$method_missing.$$p = block;
      }

      return self.$method_missing.apply(self, [symbol].concat(args));
    }
  end

  def !
    false
  end

  def instance_eval(&block)
    Kernel.raise ArgumentError, "no block given" unless block

    %x{
      var old = block.$$s,
          result;

      block.$$s = null;
      result = block.call(self, self);
      block.$$s = old;

      return result;
    }
  end

  def instance_exec(*args, &block)
    Kernel.raise ArgumentError, "no block given" unless block

    %x{
      var block_self = block.$$s,
          result;

      block.$$s = null;
      result = block.apply(self, args);
      block.$$s = block_self;

      return result;
    }
  end

  def method_missing(symbol, *args, &block)
    Kernel.raise NoMethodError, `self.$inspect && !self.$inspect.$$stub` ?
      "undefined method `#{symbol}' for #{inspect}:#{`self.$$class`}" :
      "undefined method `#{symbol}' for #{`self.$$class`}"
  end
end
