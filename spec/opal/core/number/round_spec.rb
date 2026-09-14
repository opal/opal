# backtick_javascript: true

require 'spec_helper'

describe 'Number#round' do
  # NOTE: ruby/spec only covers -1.4 / -2.8 for negative values, i.e. never an
  # exact halfway case, so these cases are added here (see also the Integer
  # branch of Number#round, which already rounds away from zero).
  it 'rounds halfway cases away from zero' do
    0.5.round.should == 1
    2.5.round.should == 3
    -0.5.round.should == -1
    -1.5.round.should == -2
    -2.5.round.should == -3
  end

  it 'rounds halfway cases away from zero when given a precision' do
    1.25.round(1).should == 1.3
    -1.25.round(1).should == -1.3
    -1.35.round(1).should == -1.4
    2.675.round(2).should == 2.68
    -2.675.round(2).should == -2.68
  end

  it 'rounds non-halfway negative values to the nearest value' do
    -1.4.round.should == -1
    -2.8.round.should == -3
    -0.4.round.should == 0
    -1.234.round(2).should == -1.23
  end

  it 'rounds negative values with a negative precision away from zero' do
    123456.78.round(-2).should == 123500
    -123456.78.round(-2).should == -123500
    0.8346268.round(-1).should == 0
  end
end
