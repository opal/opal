class Proc
  `def.$$is_proc = true`
  `def.$$is_lambda = false`

  def self.new(&block)
    unless block
      raise ArgumentError, "tried to create a Proc object without a block"
    end

    block
  end

  def call(*args, &block)
    %x{
      if (block !== nil) {
        self.$$p = block;
      }

      var result;

      if (self.$$is_lambda) {
        result = self.apply(null, args);
      }
      else {
        result = Opal.yieldX(self, args);
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
    `!!self.$$is_lambda`
  end

  # FIXME: this should support the various splats and optional arguments
  def arity
    `self.length`
  end
end
