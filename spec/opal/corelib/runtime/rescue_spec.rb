require 'spec_helper'

class RescueReturningSpec
  def single
    begin
      raise "ERROR"
    rescue
      :foo
    end
  end

  def multiple
    begin
      raise "ERROR"
    rescue
      to_s
      :bar
    end
  end

  def empty_rescue
    begin
      raise "ERROR"
    rescue
    end
  end
end

describe "The rescue keyword" do
  it "returns last value of expression evaluated" do
    RescueReturningSpec.new.single.should == :foo
    RescueReturningSpec.new.multiple.should == :bar
  end

  it "returns nil if no expr given in rescue body" do
    RescueReturningSpec.new.empty_rescue.should be_nil
  end
end
