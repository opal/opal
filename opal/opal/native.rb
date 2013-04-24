class Native < BasicObject
  def initialize(native)
    %x{
      if (#{native} == null) {
        #{ Kernel.raise "null or undefined passed to Native" };
      }
    }

    @native = native
  end

  def method_missing(symbol, *args, &block)
    native = @native

    %x{
      var prop = #{native}[#{symbol}];

      if (typeof(prop) === 'function') {
        return prop.apply(#{native}, #{args});
      }
      else if (symbol.charAt(symbol.length - 1) === '=') {
        prop = symbol.slice(0, symbol.length - 1);
        return #{native}[prop] = args[0];
      }
      else if (prop != null) {
        return prop;
      }
    }

    nil
  end

  def [](key)
    %x{
      var value = #{@native}[key];

      if (value == null) return #{nil};

      return value;
    }
  end

  def ==(other)
    `#{@native} === #{other}.native`
  end

  def to_native
    @native
  end
end
