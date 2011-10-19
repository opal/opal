class Proc
  def self.new(&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    block
  end

  def to_proc
    self
  end

  # TODO: ability to pass a block
  def call(*args)
    `return self.apply(null, [self.$S, null].concat(args));`
  end

  def to_s
    "#<Proc:0x#{`(self.$h() * 400487).toString(16)`}#{' (lambda)' if lambda?}>"
  end

  def lambda?
    `self.$lambda`
  end
end
