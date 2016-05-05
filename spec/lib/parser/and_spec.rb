require 'support/parser_helpers'

describe "The and statement" do
  next "Migrating to the 'parser' gem..."
  it "should always return s(:and)" do
    parsed("1 and 2").should == [:and, [:int, 1], [:int, 2]]
  end
end

describe "The && expression" do
  next "Migrating to the 'parser' gem..."
  it "should always return s(:and)" do
    parsed("1 && 2").should == [:and, [:int, 1], [:int, 2]]
  end
end
