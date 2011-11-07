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
    `console.log(self);`
    `return self.apply(self.$S, args);`
  end

  def to_s
    "#<Proc:0x#{hash}#{' (lambda)' if lambda?}>"
  end

  def lambda?
    `self.$lambda ? true : false`
  end

  def arity
    1
  end
end
