require "spec_helper"

describe "Enumerator#new" do
  it "creates a new custom enumerator with the given object, iterator and arguments" do
    enum = enumerator_class.new(1, :upto, 3)
    enum.should be_kind_of(Enumerator)
  end

  it "creates a new custom enumerator that responds to #each" do
    enum = enumerator_class.new(1, :upto, 3)
    enum.respond_to?(:each).should == true
  end

  it "creates a new custom enumerator that runs correctly" do
    enumerator_class.new(1, :upto, 3).map{|x|x}.should == [1,2,3]
  end
end
