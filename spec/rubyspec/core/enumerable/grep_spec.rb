require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

class EnumerableSpecGrep
  def ===(obj); obj == '2'; end
end

class EnumerableSpecGrep2
  def ===(obj); /^ca/ =~ obj; end
end

describe "Enumerable#grep" do
  before(:each) do
    @a = EnumerableSpecs::EachDefiner.new(2, 4, 6, 8, 10)
  end

  it "grep without a block should return an array of all elements === pattern" do
    EnumerableSpecs::Numerous.new('2', 'a', 'nil', '3', false).grep(EnumerableSpecGrep.new).should == ['2']
  end

  it "grep with a block should return an array of elements === pattern passed through block" do
    EnumerableSpecs::Numerous.new("cat", "coat", "car", "cadr", "cost").grep(EnumerableSpecGrep2.new) { |i| i.upcase }.should == ["CAT", "CAR", "CADR"]
  end
end
