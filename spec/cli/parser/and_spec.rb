require 'support/parser_helpers'

describe "The and statement" do
  it "should always return s(:and)" do
    parsed("1 and 2").should == [:and, [:int, 1], [:int, 2]]
  end
end

describe "The && expression" do
  it "should always return s(:and)" do
    parsed("1 && 2").should == [:and, [:int, 1], [:int, 2]]
  end
end
