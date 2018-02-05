describe "Array#dup" do
  it "should use slice optimization" do
    a = Array.new
    `a.slice = function() { return ['sliced'] }`
    lambda { a.dup }.should_not raise_error
    a.dup.should == ['sliced']
  end

  it "should use slice optimization on Array subclass" do
    subclass = Class.new(Array)
    a = subclass.new
    `a.slice = function() { return ['sliced'] }`
    lambda { a.dup }.should_not raise_error
    a.dup.should == ['sliced']
  end

  it "should not use slice optimization when allocation is redefined" do
    subclass = Class.new(Array)
    a = subclass.new
    subclass.define_singleton_method(:allocate) { raise 'Overriden method, no slice optimization for you!' }
    lambda { a.dup }.should raise_error # dup should call allocate because the method is overriden
  end
end
