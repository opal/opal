require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Comparable#between?" do
  it "returns true if self is greater than or equal to the first and less than or equal to the second argument" do
    a = ComparableSpecs::Weird.new(-1)
    b = ComparableSpecs::Weird.new(0)
    c = ComparableSpecs::Weird.new(1)
    d = ComparableSpecs::Weird.new(2)

    a.between?(a, a).should == true
  end
end
