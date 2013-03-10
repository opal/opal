class Native
  def initialize(native)
    %x{
      if (#{native} == null) {
        #{ raise "null or undefined passed to Native" };
      }
    }

    @native = native
  end

  def method_missing(symbol, *args, &block)
    native = @native

    %x{
      var func;

      if (func = #{native}[#{symbol}]) {
        return func.call(#{native});
      }
    }

    nil
  end

  def to_native
    @native
  end
end
