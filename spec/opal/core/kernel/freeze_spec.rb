# No real support, just mocking

describe "Kernel#freeze" do
  it 'responds to #freeze and #frozen?' do
    o = double('o')
    expect(o.frozen?).to be_false
    o.freeze
    expect(o.frozen?).to be_true
  end

  it "returns self" do
    o = Object.new
    expect(o.freeze).to equal(o)
  end
end
