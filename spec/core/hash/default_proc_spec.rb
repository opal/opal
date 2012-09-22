describe "Hash#default_proc" do
  it "returns the block passed to Hash.new" do
    h = Hash.new { |i| 'Paris' }
    p = h.default_proc
    p.call(1).should == 'Paris'
  end

  it "returns nil if no block was passed to proc" do
    {}.default_proc.should == nil
  end
end

describe "Hash#default_proc=" do
  it "replaces the block passed to Hash.new" do
    h = Hash.new { |i| 'Paris' }
    h.default_proc = Proc.new { 'Montreal' }
    p = h.default_proc
    p.call(1).should == 'Montreal'
  end
end