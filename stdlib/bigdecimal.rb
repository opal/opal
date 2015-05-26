  require 'bigdecimal/bignumber.js'
class BigDecimal


  def initialize(value)
    value = value.gsub("_", "")
    value = value.gsub("d", "E")
    value = value.gsub("D", "E")
    value = value.gsub("e", "E")
    value = value.gsub("E", "E")
    value = value.strip
    
    x = value.match(/^[\-|\+]?[0-9]*([\.][0-9]*)?([E][\-|\+]?[0-9]*)?/)

    value = "0.0"
    value = x[0] if x && x[0] && x[0] != ""

    @value = `new forge.BigNumber(#{value})`
  end

  def -@
    value = `#{@value}.neg()`
    BigDecimal.new `value.toString()`
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
