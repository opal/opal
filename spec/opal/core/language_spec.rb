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
