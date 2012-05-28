describe "String#start_with?" do
  it "returns true only if beginning match" do
    s = "hello"
    s.start_with?('h').should be_true
    s.start_with?('hel').should be_true
    s.start_with?('el').should be_false
  end

  it "returns true only if any beginning match" do
    "hello".start_with?('x', 'y', 'he', 'z').should be_true
  end
end