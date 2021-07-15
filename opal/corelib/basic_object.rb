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
    %x{
      if (self[Opal.s.$$id] != null) {
        return self[Opal.s.$$id];
      }
      Opal.defineProperty(self, Opal.s.$$id, Opal.uid());
      return self[Opal.s.$$id];
    }
  end

  def __send__(symbol, *args, &block)
    %x{
      var func = self[Opal.s('$' + symbol)]

      if (func) {
        if (block !== nil) {
          func[Opal.s.$$p] = block;
        }

        return func.apply(self, args);
      }

      if (block !== nil) {
        self[Opal.s.$method_missing][Opal.s.$$p] = block;
      }

      return self[Opal.s.$method_missing].apply(self, [symbol].concat(args));
    }
  end

  def !
    false
  end

  def !=(other)
    !(self == other)
  end

  def instance_eval(*args, &block)
    if block.nil? && `!!Opal.compile`
      ::Kernel.raise ::ArgumentError, 'wrong number of arguments (0 for 1..3)' unless (1..3).cover? args.size

      string, file, _lineno = *args
      default_eval_options = { file: (file || '(eval)'), eval: true }
      compiling_options = __OPAL_COMPILER_CONFIG__.merge(default_eval_options)
      compiled = ::Opal.compile string, compiling_options
      block = ::Kernel.proc do
        %x{
          return (function(self) {
            return eval(compiled);
          })(self)
        }
      end
    elsif args.any?
      ::Kernel.raise ::ArgumentError, "wrong number of arguments (#{args.size} for 0)"
    end

    %x{
      var old = block[Opal.s.$$s],
          result;

      block[Opal.s.$$s] = null;

      // Need to pass $$eval so that method definitions know if this is
      // being done on a class/module. Cannot be compiler driven since
      // send(:instance_eval) needs to work.
      if (self[Opal.s.$$is_a_module]) {
        self[Opal.s.$$eval] = true;
        try {
          result = block.call(self, self);
        }
        finally {
          self[Opal.s.$$eval] = false;
        }
      }
      else {
        result = block.call(self, self);
      }

      block[Opal.s.$$s] = old;

      return result;
    }
  end

  def instance_exec(*args, &block)
    ::Kernel.raise ::ArgumentError, 'no block given' unless block

    %x{
      var block_self = block[Opal.s.$$s],
          result;

      block[Opal.s.$$s] = null;

      if (self[Opal.s.$$is_a_module]) {
        self[Opal.s.$$eval] = true;
        try {
          result = block.apply(self, args);
        }
        finally {
          self[Opal.s.$$eval] = false;
        }
      }
      else {
        result = block.apply(self, args);
      }

      block[Opal.s.$$s] = block_self;

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
    message = if `self[Opal.s.$inspect] && !self[Opal.s.$inspect][Opal.s.$$stub]`
                "undefined method `#{symbol}' for #{inspect}:#{`self[Opal.s.$$class]`}"
              else
                "undefined method `#{symbol}' for #{`self[Opal.s.$$class]`}"
              end

    ::Kernel.raise ::NoMethodError.new(message, symbol)
  end

  def respond_to_missing?(method_name, include_all = false)
    false
  end
end
