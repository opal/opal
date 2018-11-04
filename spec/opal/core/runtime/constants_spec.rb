describe "Missing constants" do
  it "should raise a NameError when trying to access an undefined constant" do
    lambda { ThisConstantDoesNotExist }.should raise_error(NameError)
  end

  it "raises an error for missing constants on base constant scope" do
    lambda { Object::SomeRandomObjectName }.should raise_error(NameError)
  end

  it "raises an error for missing constants on root constant scope" do
    lambda { ::YetAnotherMissingConstant }.should raise_error(NameError)
  end
end

module RuntimeFixtures
  class A
  end

  class A::B
  end
end

describe "Constants access via .$$ with dots (regression for #1418)" do
  it "allows to acces scopes on `Opal`" do
    `Opal.RuntimeFixtures.A.B`.should == RuntimeFixtures::A::B
  end
end
