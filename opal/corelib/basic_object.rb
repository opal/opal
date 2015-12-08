class BasicObject
  def initialize(*)
  end

  def ==(other)
    `self === other`
  end

  def eql?(other)
    self == other
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

  def !=(other)
    !(self == other)
  end

  alias equal? ==

  def instance_eval(*args, &block)
    if block.nil? && `!!Opal.compile`
      Kernel.raise ArgumentError, "wrong number of arguments (0 for 1..3)" unless (1..3).cover? args.size

      string, file, _lineno = *args
      compiled = Opal.compile string, file: (file || '(eval)'), eval: true
      wrapper  = `function() {return eval(compiled)}`

      block = Kernel.lambda { `wrapper.call(#{self})` }
    elsif args.size > 0
      Kernel.raise ArgumentError, "wrong number of arguments (#{args.size} for 0)"
    end

    %x{
      var old = block.$$s,
          result;

      block.$$s = null;

      // Need to pass $$eval so that method definitions know if this is
      // being done on a class/module. Cannot be compiler driven since
      // send(:instance_eval) needs to work.
      if (self.$$is_class || self.$$is_module) {
        self.$$eval = true;
        try {
          result = block.call(self, self);
        }
        finally {
          self.$$eval = false;
        }
      }
      else {
        result = block.call(self, self);
      }

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

      if (self.$$is_class || self.$$is_module) {
        self.$$eval = true;
        try {
          result = block.apply(self, args);
        }
        finally {
          self.$$eval = false;
        }
      }
      else {
        result = block.apply(self, args);
      }

      block.$$s = block_self;

      return result;
    }
  end

  def singleton_method_added(*)
  end

  def singleton_method_removed(*)
  end

  def singleton_method_undefined(*)
  end

  def method_missing(symbol, *args, &block)
    Kernel.raise NoMethodError.new(`self.$inspect && !self.$inspect.$$stub` ?
      "undefined method `#{symbol}' for #{inspect}:#{`self.$$class`}" :
      "undefined method `#{symbol}' for #{`self.$$class`}", symbol)
  end
end
