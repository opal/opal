  require 'bigdecimal/bignumber.js'
class BigDecimal

  attr_accessor :value

  def initialize(value, precision = 0)
    set_precision(precision)
    begin
      value = value.strip

      createInfinityAndNaN(value)
      normalizeAndCreateImpl(value) unless @value
    rescue
      @value = `new forge.BigNumber("0.0")`
    end
  end

  def set_precision(precision)
    precision = 20 if precision == 0
    @precision = precision
    `forge.BigNumber.config({ DECIMAL_PLACES: #{precision}})`
  end

  def normalizeAndCreateImpl(value)
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

  def createInfinityAndNaN(value)
    if value == "Infinity" || value == "+Infinity"
      @value = `new forge.BigNumber("Infinity")`
    elsif value == "-Infinity" 
      @value = `new forge.BigNumber("-Infinity")`
    elsif value == "NaN"
      @value = `new forge.BigNumber(NaN)`
    end
  end

  def precs
    [`#{@value}.precision()`, `#{@value}.maxPrecision()`]
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
      else
        return 1;
      end
    end
  end

  def wrapped_value_of(other)
    if other.kind_of?(BigDecimal)
      other = other.value
    else
      other = `new forge.BigNumber(#{other.to_s})` if other.kind_of?(Numeric)
    end
    other
  end

  def ==(other)
    if !finite?
      return self.infinite? == other.infinite?
    end
    if self.nan?
      return other.nan?
    end
    other = wrapped_value_of(other)
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
    "#{precs[0]}:#{to_s}"
  end

  def inspect
    to_s
  end

end
