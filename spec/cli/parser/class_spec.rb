require 'support/parser_helpers'

describe "The class keyword" do
  it "returns an empty s(:block) when given an empty body" do
    expect(parsed('class A; end')).to eq([:class, [:const, :A], nil, [:block]])
  end

  it "does not place single expressions into a s(:block)" do
    expect(parsed('class A; 1; end')).to eq([:class, [:const, :A], nil, [:int, 1]])
  end

  it "adds multiple body expressions into a s(:block)" do
    expect(parsed('class A; 1; 2; end')).to eq([:class, [:const, :A], nil, [:block, [:int, 1], [:int, 2]]])
  end

  it "uses nil as a placeholder when no superclass is given" do
    expect(parsed('class A; end')[2]).to eq(nil)
  end

  it "reflects the given superclass" do
    expect(parsed('class A < B; end')[2]).to eq([:const, :B])
  end

  it "should accept just a constant for the class name" do
    expect(parsed('class A; end')[1]).to eq([:const, :A])
  end

  it "should accept a prefix constant for the class name" do
    expect(parsed('class ::A; end')[1]).to eq([:colon3, :A])
  end

  it "should accept a nested constant for the class name" do
    expect(parsed('class A::B; end')[1]).to eq([:colon2, [:const, :A], :B])
  end
end
