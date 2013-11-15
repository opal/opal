describe "String#concat" do
  it "concatinate original string with other string" do
    "hello ".concat("world").should == "hello world"
  end

  it "concatinate original string with incompatible object" do
    class A; end

    lambda { "hello ".concat(A.new) }.should raise_error TypeError
  end
end
