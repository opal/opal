class Proc
  `def._isProc = true`
  `def.is_lambda = true`

  def self.new(&block)
    `if (block === nil) no_block_given();`
    `block.is_lambda = false`
    block
  end

  def call(*args)
    %x{
      var result = #{self}.apply(null, #{args});

      if (result === __breaker) {
        return __breaker.$v;
      }

      return result;
    }
  end

  alias [] call

  def to_proc
    self
  end

  def lambda?
    # This method should tell the user if the proc tricks are unavailable,
    # (see Proc#lambda? on ruby docs to find out more).
    `!!#{self}.is_lambda`
  end

  def arity
    `#{self}.length - 1`
  end

  def to_n
    self
  end
end

class Method < Proc; end
