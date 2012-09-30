class OpalMethodCallingSpec
  def foo(a)
    42 + a
  end

  def self.bar
    3.142
  end
end

describe "Calling methods" do
  it "should support '::' syntax" do
    OpalMethodCallingSpec::bar.should == 3.142
    OpalMethodCallingSpec.new.foo(10).should == 52
  end
end