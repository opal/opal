describe "Missing constants" do
  it "should raise a NameError when trying to access an undefined constant" do
    expect { ThisConstantDoesNotExist }.to raise_error(NameError)
  end

  it "raises an error for missing constants on base constant scope" do
    expect { Object::SomeRandomObjectName }.to raise_error(NameError)
  end

  it "raises an error for missing constants on root constant scope" do
    expect { ::YetAnotherMissingConstant }.to raise_error(NameError)
  end
end
