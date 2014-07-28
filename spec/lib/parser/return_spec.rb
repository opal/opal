require 'support/parser_helpers'

describe "The return keyword" do
  it "should return s(:return) when given no arguments" do
    parsed("return").should == [:return]
  end

  it "returns s(:return) with the direct argument when given one argument" do
    parsed("return 1").should == [:return, [:int, 1]]
    parsed("return *2").should == [:return, [:splat, [:int, 2]]]
  end

  it "returns s(:return) with an s(:array) when args size > 1" do
    parsed("return 1, 2").should == [:return, [:array, [:int, 1], [:int, 2]]]
    parsed("return 1, *2").should == [:return, [:array, [:int, 1], [:splat, [:int, 2]]]]
  end
end
