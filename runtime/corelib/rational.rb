class Rational
  attr_reader :numerator, :denominator

  def initialize (numerator, denominator = 1)
    @numerator   = numerator
    @denominator = denominator
  end

  def to_s
    "#{numerator}#{"/#{denominator}" if denominator}"
  end

  def inspect
    "(#{to_s})"
  end
end
