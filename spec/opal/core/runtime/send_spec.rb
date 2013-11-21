class RuntimeOpalSendSpec
  def simple
    42
  end

  def args *a
    a
  end

  def method_missing sym, *args
    [sym, args]
  end
end


describe "Opal.send()" do
  before do
    @obj = RuntimeOpalSendSpec.new
  end

  it "calls receiver with given method" do
    `Opal.send(#{@obj}, "simple")`.should == 42
  end

  it "sends any arguments to the method" do
    `Opal.send(#{@obj}, "args", 1, 2, 3)`.should == [1, 2, 3]
  end

  it "calls method_missing on the object if method doesnt exist" do
    `Opal.send(#{@obj}, "blah")`.should == [:blah, []]
    `Opal.send(#{@obj}, "bleh", 1)`.should == [:bleh, [1]]
    `Opal.send(#{@obj}, "blih", 1, 2)`.should == [:blih, [1, 2]]
  end
end
