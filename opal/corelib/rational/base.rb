module ::Kernel
  def Rational(numerator, denominator = 1)
    ::Rational.convert(numerator, denominator)
  end
end

class ::String
  def to_r
    ::Rational.from_string(self)
  end
end
