require 'bigdecimal/bignumber.min.js'

class BigDecimal

  def initialize(value)
    @value = `new BigNumber(#{value})`
  end


  def ==(other)

    puts other
    puts other.class
    `#{@value}.equals(#{other})`
  end

end
