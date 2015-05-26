  require 'bigdecimal/bignumber.js'
class BigDecimal


  def initialize(value, precision = 0)
      value = value.strip
    if value == "Infinity" 
      @value = `new forge.BigNumber("Infinity")`
    elsif value == "+Infinity" 
      @value = `new forge.BigNumber("Infinity")`
    elsif value == "-Infinity" 
      @value = `new forge.BigNumber("-Infinity")`
    elsif value == "NaN"
      @value = `new forge.BigNumber(NaN)`
    else
      value = value.gsub("_", "")
      value = value.gsub("d", "E")
      value = value.gsub("D", "E")
      value = value.gsub("e", "E")
      value = value.gsub("E", "E")
      
      x = value.match(/^[\-|\+]?[0-9]*([\.][0-9]*)?([E][\-|\+]?[0-9]*)?/)

      value = "0.0"
      value = x[0] if x && x[0] && x[0] != "" && x[0] != "-" && x[0] != "+"
      @value = `new forge.BigNumber(#{value})`
    end

  end

  def -@
    value = `#{@value}.neg()`
    BigDecimal.new `value.toString()`
  end

  def +@
    BigDecimal.new `value.toString()`
  end

  def nan?
    `#{@value}.isNaN()`
  end

  def finite?
    `#{@value}.isFinite()`
  end

  def infinite?
    if !`#{@value}.isFinite()`
      if `#{@value}.isNeg()`
        return -1;
      end
      return 1;
    end
    return false
  end

  def ==(other)
    if !finite?
      return !other.finite?
    end
    if self.nan?
      return other.nan?
    end
    return `#{@value}.equals(#{other})`
  end

  def >(other)
    `#{@value}.greaterThan(#{other})`
  end

  def <(other)
    `#{@value}.lessThan(#{other})`
  end
  def to_s
    if self.nan?
      return "NaN"
    end
    if !self.finite?
      return "Infinite"
    end
    c = `#{@value}.c`.join 
    c = c.sub(/0*$/,"")

    e = `#{@value}.e` + 1 

    s = `#{@value}.s`
    if s == -1
      sign = "-"
    end
    "#{sign}0.#{c}E#{e}"
  end

  def _dump
    to_s
  end

  def inspect
    to_s
  end

end
