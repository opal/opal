require 'spec_helper'

describe "Begin block" do
  it "can be used as an expression" do
    foo = begin
            self.class
            200
          end

    foo.should == 200

    begin
      self.class
      42
    end.should == 42

    begin
      3.142
    end.should == 3.142
  end

  it "can be used as part of an optional assignment" do
    count = 0
    foo = nil

    runner = proc do
      foo ||= begin
                count += 1
                count
              end
    end

    runner.call
    foo.should == 1

    runner.call
    foo.should == 1
  end
end
