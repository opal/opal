require 'support/parser_helpers'

describe "The super keyword" do
  it "should return s(:super) for any arguments" do
    expect(parsed("super 1")).to eq([:super, [:arglist, [:int, 1]]])
    expect(parsed("super 1, 2")).to eq([:super, [:arglist, [:int, 1], [:int, 2]]])
    expect(parsed("super 1, *2")).to eq([:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]])
  end

  it "should set nil for args when no arguments or parans" do
    expect(parsed("super")).to eq([:super, nil])
  end

  it "should always return s(:super) with :arglist when parans are used" do
    expect(parsed("super()")).to eq([:super, [:arglist]])
    expect(parsed("super(1)")).to eq([:super, [:arglist, [:int, 1]]])
    expect(parsed("super(1, 2)")).to eq([:super, [:arglist, [:int, 1], [:int, 2]]])
    expect(parsed("super(1, *2)")).to eq([:super, [:arglist, [:int, 1], [:splat, [:int, 2]]]])
  end
end
