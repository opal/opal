class Proc < `Function`
  %x{
    Proc_prototype._isProc = true;
  }

  def self.new(&block)
    `if (block === nil) no_block_given();`

    block
  end

  def to_proc
    self
  end

  def call(*args)
    `#{self}.apply(null, [#{self}._s, ''].concat(#{args}))`
  end

  def to_proc
    self
  end

  def lambda?
    `!!this.$lambda`
  end

  def arity
    `this.length - 1`
  end
end