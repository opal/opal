require 'spec_helper'

describe "Hash.new" do
  before { @subclass = Class.new(Hash) }

  it "returns a hash with the right class" do
    Hash.new.class.should == Hash
    @subclass.new.class.should == @subclass
  end
end
