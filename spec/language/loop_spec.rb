require File.expand_path('../../spec_helper', __FILE__)

describe "The loop expression" do
  it "repeats the given block until a break is called" do
    outer_loop = 0
    loop do
      outer_loop += 1
      break if outer_loop == 10
    end
    outer_loop.should == 10
  end

  it "executes code in its own scope" do
    loop do
      inner_loop = 123
      break
    end
    lambda { inner_loop }.should raise_error(NameError)
  end

  it "returns the value passed to break if interrupted by break" do
    loop do
      break 123
    end.should == 123
  end

  it "returns nil if interrupted by break with no arguments" do
    loop do
      break
    end.should == nil
  end
end
