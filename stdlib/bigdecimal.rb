  require 'bigdecimal/bignumber.js'
class BigDecimal


  def initialize(value)
    @value = `new forge.BigNumber(#{value})`
  end

  def ==(other)

    puts other
    puts other.class
    `#{@value}.equals(#{other})`
  end

end
