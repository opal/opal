class Native < BasicObject
  def self.global
    @global ||= Native.new(`Opal.global`)
  end

  def self.[](key)
    global[key]
  end

  def initialize(native)
    %x{
      if (#{native} == null) {
        #{ Kernel.raise "null or undefined passed to Native" };
      }
    }

    @native = native
  end

  def each(&block)
    %x{
      var n = #{@native}, value;

      for (var key in n) {
        value = n[key];

        if (value == null) {
          value = nil;
        }
        else if (typeof(value) === 'object') {
          if (!value._klass) {
            value = #{Native.new `value`};
          }
        }

        block(key, value);
      }
    }
  end

  def key? name
    `#{@native}[name] != null`
  end

  def method_missing(symbol, *args, &block)
    native = @native

    %x{
      var prop = #{native}[#{symbol}];

      if (typeof(prop) === 'function') {
        prop = prop.apply(#{native}, #{args.to_native});

        if (typeof(prop) === 'object' || typeof(prop) === 'function') {
          if (!prop._klass) {
            return #{ Native.new `prop` };
          }
        }

        return prop;
      }
      else if (symbol.charAt(symbol.length - 1) === '=') {
        prop = symbol.slice(0, symbol.length - 1);
        return #{native}[prop] = args[0];
      }
      else if (prop != null) {
        if (typeof(prop) === 'object') {
          if (!prop._klass) {
            return #{Native.new `prop`};
          }
        }
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

  alias respond_to? key?

  def to_a
    %x{
      var n = #{@native}, result;

      if (n.length) {
        result = [];

        for (var i = 0, len = n.length; i < len; i++) {
          result.push(#{ Native.new `n[i]` });
        }
      }
      else {
        result = [n];
      }

      return result;
    }
  end

  def to_native
    @native
  end
end

$global = Native.global
$window = $global
$document = $window.document

