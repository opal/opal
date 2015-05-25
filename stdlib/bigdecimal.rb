  require 'bigdecimal/bignumber.js'
class BigDecimal


  def initialize(value)
    @value = `new forge.BigNumber(#{value})`
  end

  def ==(other)

    `#{@value}.equals(#{other})`
  end

  def to_s
    c = `#{@value}.c`.join
    c = c.sub(/0*$/,"")

    e = `#{@value}.e` + 1 

    s = `#{@value}.s`
    if s == -1
      sign = "-"
    end
    "#{sign}0.#{c}E#{e}"
  end

  def inspect
    to_s
  end

end
