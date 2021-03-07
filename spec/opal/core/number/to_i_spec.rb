require 'spec_helper'

describe 'Number#to_i' do
  it "should not change huge number" do
    1504642339053716000000.to_i.should == 1504642339053716000000
  end

  it "should not change negative huge number" do
    -1504642339053716000000.to_i.should == -1504642339053716000000
  end

  it "equals Number#truncate(0) with huge number" do
    1504642339053716000000.to_i.should == 1504642339053716000000.truncate(0)
  end

  it "should not change Infinity" do
    `Infinity`.to_i.should == `Infinity`
  end

  it "should not change -Infinity" do
    `-Infinity`.to_i.should == `-Infinity`
  end

  it "should not change NaN" do
    x = `NaN`.to_i
    `Number.isNaN(x)`.should be_true
  end
end
