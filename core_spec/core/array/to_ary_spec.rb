require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#to_ary" do
  it "returns self" do
    a = [1, 2, 3]
    a.should equal(a.to_ary)
  end
end
