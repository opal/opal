# backtick_javascript: true

require 'spec_helper'

describe 'Number#**' do
  # An Integer raised to 0 is 1 — including for 0 and negative bases. Before this
  # was fixed, a zero exponent took the Rational branch and returned Rational(1)
  # (and recursed, see the "returns self raised to the given power" ruby/spec case).
  it 'returns 1 for a zero exponent' do
    (2**0).should == 1
    (10**0).should == 1
    (0**0).should == 1
    ((-7)**0).should == 1
  end

  it 'returns an Integer (not a Rational) for a zero exponent' do
    (10**0).is_a?(Rational).should be_false
    (10**0).is_a?(Integer).should be_true
  end

  it 'still returns a Rational for a negative exponent' do
    (2**-1).should == Rational(1, 2)
    (2**-2).should == Rational(1, 4)
  end
end
