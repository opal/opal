require 'spec_helper'

describe "generated method names" do
  it "does not conflict with local Ruby variables" do
    Class.new {
      value = 123
      def value
        456
      end
      value.should == 123
    }
  end

  it "does not conflict with local JS variables" do
    Class.new {
      `var value = 123;`
      def value
        456
      end
      `value`.should == 123
    }
  end
end

describe "Bridging" do
  it "does not remove singleton methods of bridged classes" do
    `typeof(String.call)`.should == "function"
  end
end

describe "Constants" do
  it "doesn't raise error when a JS falsey constant is referenced" do
    z = Class.new {
      C1 = 0
      C2 = nil
      C3 = false
      C4 = ''
      C5 = C3
    }

    [z::C1, z::C2, z::C3, z::C4, z::C5].should == [0, nil, false, '', false]
  end
end
