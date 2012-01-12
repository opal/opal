require File.expand_path('../../spec_helper', __FILE__)

describe "Hash literal" do
  it "{} should return an empty hash" do
    {}.size.should == 0
    {}.should == {}
  end

  it "{} should return a new hash populated with the given elements" do
    h = {:a => 'a', 'b' => 3, 44 => 2.3}
    h.size.should == 3
    h.should == {:a => 'a', 'b' => 3, 44 => 2.3}
  end

  it "treats empty expressions an nils" do
    h = {() => ()}
    h.keys.should == [nil]
    h.values.should == [nil]
    h[nil].should == nil

    h = {() => :value}
    h.keys.should == [nil]
    h.values.should == [:value]
    h[nil].should == :value

    h = {:keys => ()}
    h.keys.should == [:keys]
    h.values.should == [nil]
    h[:key].should == nil
  end

  it "checks duplicated keys on initialization" do
    h = {:foo => :bar, :foo => :foo}
    h.keys.size.should == 1
    h.should == {:foo => :foo}
  end

  it "accepts a hanging comma" do
    h = {:a => 1, :b => 2,}
    h.size.should == 2
    h.should == {:a => 1, :b => 2}
  end
end
