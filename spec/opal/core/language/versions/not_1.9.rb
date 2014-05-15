describe "not()" do
  # not(arg).method and method(not(arg)) raise SyntaxErrors on 1.8. Here we
  # use #inspect to test that the syntax works on 1.9

  it "can be used as a function" do
    expect do
      not(true).inspect
    end.not_to raise_error
  end

  it "returns false if the argument is true" do
    expect(not(true).inspect).to eq("false")
  end

  it "returns true if the argument is false" do
    expect(not(false).inspect).to eq("true")
  end

  it "returns true if the argument is nil" do
    expect(not(nil).inspect).to eq("true")
  end
end