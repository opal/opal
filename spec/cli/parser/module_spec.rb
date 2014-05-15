require 'support/parser_helpers'

describe "The module keyword" do
  it "returns an empty s(:block) when given an empty body" do
    expect(parsed('module A; end')).to eq([:module, [:const, :A], [:block]])
  end

  it "does not place single expressions into a s(:block)" do
    expect(parsed('module A; 1; end')).to eq([:module, [:const, :A], [:int, 1]])
  end

  it "adds multiple body expressions into a s(:block)" do
    expect(parsed('module A; 1; 2; end')).to eq([:module, [:const, :A], [:block, [:int, 1], [:int, 2]]])
  end

  it "should accept just a constant for the module name" do
    expect(parsed('module A; end')[1]).to eq([:const, :A])
  end

  it "should accept a prefix constant for the module name" do
    expect(parsed('module ::A; end')[1]).to eq([:colon3, :A])
  end

  it "should accepts a nested constant for the module name" do
    expect(parsed('module A::B; end')[1]).to eq([:colon2, [:const, :A], :B])
  end
end
