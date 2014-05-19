class RespondToSpecs
  def self.bar
    'done'
  end

  def undefed_method
    true
  end

  undef undefed_method

  def some_method
    :foo
  end
end

describe "Kernel.respond_to?" do
  it "indicates if a singleton object responds to a particular message" do
    expect(RespondToSpecs.respond_to?(:bar)).to eq(true)
    expect(RespondToSpecs.respond_to?(:baz)).to eq(false)
  end
end

describe "Kernel#respond_to?" do
  before :each do
    @a = RespondToSpecs.new
  end

  it "returns true if a method exists" do
    expect(@a.respond_to?(:some_method)).to be_true
  end

  it "indicates if an object responds to a message" do
    expect(@a.respond_to?(:undefed_method)).to be_false
  end

  it "returns false if a method exists, but is marked with a 'rb_stub' property" do
    `#{@a}.$some_method.rb_stub = true`
    expect(@a.respond_to?(:some_method)).to be_false
  end
end
