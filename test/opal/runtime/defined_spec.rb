describe "The defined? keyword for x-strings" do
  it "returns true for defined variables" do
    `var SomeClass = {}`
    defined?(`{}`).should be_true
    defined?(`SomeClass`).should be_true
  end

  it "retuens false for undefined variables" do
    defined?(`SomeBadVar`).should be_false
  end
end