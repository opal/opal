class Proc
  `def._isProc = true`
  `def.is_lambda = true`

  def self.new(&block)
    `if (block === nil) { throw new Error("no block given"); }`
    `block.is_lambda = false`
    block
  end

  def call(*args, &block)
    %x{
      if (block !== nil) {
        #{self}._p = block;
      }

      var result;

      if (#{self}.is_lambda) {
        result = #{self}.apply(null, #{args});
      }
      else {
        result = Opal.$yieldX(#{self}, #{args});
      }

      if (result === $breaker) {
        return $breaker.$v;
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
    `#{self}.length`
  end

  def to_n
    self
  end
end

class Method < Proc; end
