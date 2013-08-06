require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#delete" do
  it "removes elements that are #== to object" do
    x = mock('delete')
    def x.==(other) 3 == other end

    a = [1, 2, 3, x, 4, 3, 5, x]
    a.delete mock('not contained')
    a.should == [1, 2, 3, x, 4, 3, 5, x]

    a.delete 3
    a.should == [1, 2, 4, 5]
  end

  ruby_version_is '1.8.7' ... '1.9' do
    it "returns the argument" do
      x = mock('delete')
      y = mock('delete_more')
      def x.==(other) 3 == other end
      def y.==(other) 3 == other end

      a = [1, 2, 3, 4, 3, 5, x]

      ret = a.delete y
      ret.should equal(y)
    end
  end

  ruby_version_is '1.9' ... '2.0' do
    it "returns the last element in the array for which object is equal under #==" do
      x = mock('delete')
      y = mock('delete_more')
      def x.==(other) 3 == other end
      def y.==(other) 3 == other end

      a = [1, 2, 3, y, 4, 3, 5, x]

      ret = a.delete 3
      ret.should equal(x)
    end
  end

  it "calculates equality correctly for reference values" do
    a = ["foo", "bar", "foo", "quux", "foo"]
    a.delete "foo"
    a.should == ["bar","quux"]
  end

  it "returns object or nil if no elements match object" do
    [1, 2, 4, 5].delete(1).should == 1
    [1, 2, 4, 5].delete(3).should == nil
  end

  it "may be given a block that is executed if no element matches object" do
    [1].delete(1) {:not_found}.should == 1
    [].delete('a') {:not_found}.should == :not_found
  end

  it "returns nil if the array is empty due to a shift" do
    a = [1]
    a.shift
    a.delete(nil).should == nil
  end

  ruby_version_is '' ... '1.9' do
    it "raises a TypeError on a frozen array if a modification would take place" do
      lambda { [1, 2, 3].freeze.delete(1) }.should raise_error(TypeError)
    end

    it "returns false on a frozen array if a modification does not take place" do
      [1, 2, 3].freeze.delete(0).should == nil
    end
  end

  ruby_version_is '1.9' do
    it "raises a RuntimeError on a frozen array" do
      lambda { [1, 2, 3].freeze.delete(1) }.should raise_error(RuntimeError)
    end
  end

  it "keeps tainted status" do
    a = [1, 2]
    a.taint
    a.tainted?.should be_true
    a.delete(2)
    a.tainted?.should be_true
    a.delete(1) # now empty
    a.tainted?.should be_true
  end

  ruby_version_is '1.9' do
    it "keeps untrusted status" do
      a = [1, 2]
      a.untrust
      a.untrusted?.should be_true
      a.delete(2)
      a.untrusted?.should be_true
      a.delete(1) # now empty
      a.untrusted?.should be_true
    end
  end
end
