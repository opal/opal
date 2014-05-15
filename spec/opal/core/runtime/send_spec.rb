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
    expect(`Opal.send(#{@obj}, "simple")`).to eq(42)
  end

  it "sends any arguments to the method" do
    expect(`Opal.send(#{@obj}, "args", 1, 2, 3)`).to eq([1, 2, 3])
  end

  it "calls method_missing on the object if method doesnt exist" do
    expect(`Opal.send(#{@obj}, "blah")`).to eq([:blah, []])
    expect(`Opal.send(#{@obj}, "bleh", 1)`).to eq([:bleh, [1]])
    expect(`Opal.send(#{@obj}, "blih", 1, 2)`).to eq([:blih, [1, 2]])
  end
end
