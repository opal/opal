require File.expand_path('../../spec_helper', __FILE__)

describe "Operators" do
  it "! ~ + is right-associative" do
    (!!true).should == true
    (~~0).should == 0
    raise "this doesnt parse correctly"
    # (++2).should == 2
  end

  it "** is right-associative" do
    (2**2**3).should == 256
  end

  it "** has higher precedence than unary minus" do
    (-2**2).should == -4
  end

  it "unary minus is right-associative" do
    raise "this doesnt parse correctly"
    # (--2).should == 2
  end

  it "unary minus has higher precedence than * / %" do
    class UnaryMinusTest; def -@; 50; end; end
    b = UnaryMinusTest.new

    (-b * 5).should == 250
    (-b / 5).should == 10
    (-b % 7).should == 1
  end
end

