require 'support/parser_helpers'

describe "Singleton classes" do
  it "returns an empty s(:block) when given an empty body" do
    expect(parsed('class << A; end')[2]).to eq([:block])
  end

  it "does not place single expressions into an s(:block)" do
    expect(parsed('class << A; 1; end')[2]).to eq([:int, 1])
  end

  it "adds multiple body expressions into a s(:block)" do
    expect(parsed('class << A; 1; 2; end')[2]).to eq([:block, [:int, 1], [:int, 2]])
  end

  it "should accept any expressions for singleton part" do
    expect(parsed('class << A; end')).to eq([:sclass, [:const, :A], [:block]])
    expect(parsed('class << self; end')).to eq([:sclass, [:self], [:block]])
  end
end

