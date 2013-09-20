require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../fixtures/classes', __FILE__)

describe "SimpleDelegator.new" do
  before :all do
    @simple = DelegateSpecs::Simple.new
    @delegate = SimpleDelegator.new(@simple)
  end

  it "forwards public method calls" do
    @delegate.pub.should == :foo
  end

  ruby_version_is ""..."2.0" do
    it "forwards protected method calls" do
      @delegate.prot.should == :protected
    end
  end

  ruby_version_is "2.0" do
    it "forwards protected method calls" do
      lambda{ @delegate.prot }.should raise_error( NoMethodError )
    end
  end

  it "doesn't forward private method calls" do
    lambda{ @delegate.priv }.should raise_error( NoMethodError )
  end

  it "doesn't forward private method calls even via send or __send__" do
    lambda{ @delegate.send(:priv, 42)     }.should raise_error( NoMethodError )
    lambda{ @delegate.__send__(:priv, 42) }.should raise_error( NoMethodError )
  end
end
