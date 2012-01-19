require File.expand_path('../../../spec_helper', __FILE__)

describe "TrueClass#===" do
  it "returns true when the given object is the literal 'true'" do
    (TrueClass === true).should == true
    (TrueClass === false).should == false
    (TrueClass === nil).should == false
    (TrueClass === "").should == false
    (TrueClass === 'x').should == false
  end
end

