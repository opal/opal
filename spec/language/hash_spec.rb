require File.expand_path('../../spec_helper', __FILE__)

describe "Hash literal" do
  it "{} should return an empty hash" do
    {}.size.should == 0
    {}.should == {}
  end

  it "{} should return a new hash populated with the given elements" do
    h = {:a => 'a', 'b' => 3, 44 => 2.3}
    h.size.should == 3
    h.should == {:a => "a", "b" => 3, 44 => 2.3}
  end

  it "treats empty expressions as nils" do
    h = {() => ()}
    h.keys.should == [nil]
    h.values.should == [nil]
    h[nil].should == nil

    h = {() => :value}
    h.keys.should == [nil]
    h.values.should == [:value]
    h[nil].should == :value

    h = {:key => ()}
    h.keys.should == [:key]
    h.values.should == [nil]
    h[:key].should == nil
  end

  pending "freezes string keys on initialization" do
    key = "foo"
    h = {key => "bar"}
    key.reverse!
    h["foo"].should == "bar"
    h.keys.first.should == "foo"
    h.keys.first.frozen?.should == true
    key.should == "oof"
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
  
  it "recognizes '=' at the end of the key" do
    eval("{:a==>1}").should   == {:"a=" => 1}
    eval("{:a= =>1}").should  == {:"a=" => 1}
    eval("{:a= => 1}").should == {:"a=" => 1}
  end
  
  it "with '==>' in the middle raises SyntaxError" do
    lambda {eval("{:a ==> 1}")}.should raise_error(SyntaxError)
  end
end

# language_version __FILE__, "hash"
