# No real support, just mocking

describe "Kernel#freeze" do
  it 'responds to #freeze and #frozen?' do
    o = mock('o')
    o.frozen?.should be_false
    o.freeze
    o.frozen?.should be_true
  end

  it "returns self" do
    o = Object.new
    o.freeze.should equal(o)
  end
end
