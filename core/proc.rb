class Proc < `Function`
  %x{
    def._flags = T_OBJECT | T_PROC;
  }

  def self.new(&block)
    `if (block === nil) no_block_given();`

    block
  end

  def to_proc
    self
  end

  def call(*args)
    `this.apply(this._s, #{args})`
  end

  def to_proc
    self
  end

  def to_s
    "#<Proc:0x0000000>"
  end

  def lambda?
    `!!this.$lambda`
  end

  def arity
    `this.length - 1`
  end
end