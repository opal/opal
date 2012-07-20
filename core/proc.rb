class Proc < `Function`
  %x{
    Proc_prototype._isProc = true;
    Proc_prototype.is_lambda = true;
  }

  def self.new(&block)
    `if (block === nil) no_block_given();`
    `block.is_lambda = false`
    block
  end

  def to_proc
    self
  end

  def call(*args)
    `#{self}.apply(null, [#{self}._s].concat(#{args}))`
  end

  def to_proc
    self
  end

  def lambda?
    # This method should tell the user if the proc tricks are unavailable,
    # (see Proc#lambda? on ruby docs to find out more).
    `!!#{self}.is_lambda`
  end

  def arity
    `this.length - 1`
  end
end