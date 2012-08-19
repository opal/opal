describe "Hash.new" do
  it "creates an empty Hash if passed no arguments" do
    Hash.new.should == {}
    Hash.new.size.should == 0
  end

  it "creates a new Hash with default object if passed a default argument" do
    Hash.new(5).default.should == 5
    Hash.new({}).default.should == {}
  end

  it "creates a Hash with a default_proc if passed a block" do
    Hash.new.default_proc.should == nil

    h = Hash.new { |x| "Answer to #{x}" }
    h.default_proc.call(5).should == "Answer to 5"
    h.default_proc.call("x").should == "Answer to x"
  end
end