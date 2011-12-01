require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#+" do
  it "concatenates two arrays" do
    ([ 1, 2, 3 ] + [ 3, 4, 5 ] ).should == [1, 2, 3, 3, 4, 5]
    ([ 1, 2, 3 ] + []).should == [1, 2, 3]
    ([] + [ 1, 2, 3 ]).should == [1, 2, 3]
    ([] + []).should == []
  end

  it "can concatenate an array with itself" do
    ary = [1, 2, 3]
    (ary + ary).should == [1, 2, 3, 1, 2, 3]
  end
end
