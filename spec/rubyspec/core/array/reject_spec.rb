require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)
require File.expand_path('../shared/enumeratorize', __FILE__)

describe "Array#reject" do
  it "returns a new array without elements for which block is true" do
    ary = [1, 2, 3, 4, 5]
    ary.reject { true }.should == []
    ary.reject { false }.should == ary
    ary.reject { false }.object_id.should_not == ary.object_id
    ary.reject { nil }.should == ary
    ary.reject { nil }.object_id.should_not == ary.object_id
    ary.reject { 5 }.should == []
    ary.reject { |i| i < 3 }.should == [3, 4, 5]
    ary.reject { |i| i % 2 == 0 }.should == [1, 3, 5]
  end

  it "returns self when called on an Array emptied with #shift" do
    array = [1]
    array.shift
    array.reject { |x| true }.should == []
  end

  pending "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.reject { false }.should == [empty]
    empty.reject { true }.should == []

    array = ArraySpecs.recursive_array
    array.reject { false }.should == [1, 'two', 3.0, array, array, array, array, array]
    array.reject { true }.should == []
  end

  ruby_version_is "" ... "1.9.3" do
    not_compliant_on :ironruby do
      it "returns subclass instance on Array subclasses" do
        ArraySpecs::MyArray[1, 2, 3].reject { |x| x % 2 == 0 }.should be_kind_of(ArraySpecs::MyArray)
      end
    end if false

    deviates_on :ironruby do
      it "does not return subclass instance on Array subclasses" do
        ArraySpecs::MyArray[1, 2, 3].reject { |x| x % 2 == 0 }.should be_kind_of(Array)
      end
    end if false
  end

  ruby_version_is "1.9.3" do
    it "does not return subclass instance on Array subclasses" do
      ArraySpecs::MyArray[1, 2, 3].reject { |x| x % 2 == 0 }.should be_kind_of(Array)
    end

    it "does not retain instance variables" do
      array = []
      array.instance_variable_set("@variable", "value")
      array.reject { false }.instance_variable_get("@variable").should == nil
    end
  end

  pending do
    it_behaves_like :enumeratorize, :reject
  end
end

describe "Array#reject!" do
  it "removes elements for which block is true" do
    a = [3, 4, 5, 6, 7, 8, 9, 10, 11]
    a.reject! { |i| i % 2 == 0 }.should equal(a)
    a.should == [3, 5, 7, 9, 11]
    a.reject! { |i| i > 8 }
    a.should == [3, 5, 7]
    a.reject! { |i| i < 4 }
    a.should == [5, 7]
    a.reject! { |i| i == 5 }
    a.should == [7]
    a.reject! { true }
    a.should == []
    a.reject! { true }
    a.should == []
  end

  pending "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty_dup = empty.dup
    empty.reject! { false }.should == nil
    empty.should == empty_dup

    empty = ArraySpecs.empty_recursive_array
    empty.reject! { true }.should == []
    empty.should == []

    array = ArraySpecs.recursive_array
    array_dup = array.dup
    array.reject! { false }.should == nil
    array.should == array_dup

    array = ArraySpecs.recursive_array
    array.reject! { true }.should == []
    array.should == []
  end

  it "returns nil when called on an Array emptied with #shift" do
    array = [1]
    array.shift
    array.reject! { |x| true }.should == nil
  end

  it "returns nil if no changes are made" do
    a = [1, 2, 3]

    a.reject! { |i| i < 0 }.should == nil

    a.reject! { true }
    a.reject! { true }.should == nil
  end

  ruby_version_is "" ... "1.9" do
    it "raises a TypeError on a frozen array" do
      lambda { ArraySpecs.frozen_array.reject! {} }.should raise_error(TypeError)
    end
    it "raises a TypeError on an empty frozen array" do
      lambda { ArraySpecs.empty_frozen_array.reject! {} }.should raise_error(TypeError)
    end
  end

  ruby_version_is "1.9" do
    it "raises a RuntimeError on a frozen array" do
      lambda { ArraySpecs.frozen_array.reject! {} }.should raise_error(RuntimeError)
    end
    it "raises a RuntimeError on an empty frozen array" do
      lambda { ArraySpecs.empty_frozen_array.reject! {} }.should raise_error(RuntimeError)
    end
  end

  pending do
    it_behaves_like :enumeratorize, :reject!
  end
end
