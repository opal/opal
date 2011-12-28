class Proc
  def self.new(&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    block
  end

  def to_proc
    self
  end

  def call(*args)
    `self.apply(self.$S, $slice.call(arguments))`
  end

  def to_native
    %x{
      return function() {
        var args = Array.slice.call(arguments);
            args.unshift(null); // block

        return self.apply(self.$S, args);
      };
    }
  end

  def to_proc
    self
  end

  def to_s
    "#<Proc:0x0000000>"
  end

  def lambda?
    `self.$lambda ? true : false`
  end

  def arity
    `self.length - 1`
  end
end
