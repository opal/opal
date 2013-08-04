require 'spec_helper'

describe "Hash.allocate" do
  before { @subclass = Class.new(Hash) }

  it "returns an instance of Hash or subclass" do
    Hash.allocate.should be_kind_of Hash
    @subclass.allocate.should be_kind_of @subclass
  end

  it "should return a Hash ready to be used" do
    h = @subclass.allocate
    h[:foo] = 100
    h[:foo].should == 100
  end
end
