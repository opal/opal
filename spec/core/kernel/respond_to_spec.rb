class RespondToSpecs
  def self.bar
    'done'
  end

  def undefed_method
    true
  end

  undef undefed_method
end

describe "Kernel.respond_to?" do
  it "indicates if a singleton object responds to a particular message" do
    RespondToSpecs.respond_to?(:bar).should == true
    RespondToSpecs.respond_to?(:baz).should == false
  end
end

describe "Kernel#respond_to?" do
  before :each do
    @a = RespondToSpecs.new
  end
end