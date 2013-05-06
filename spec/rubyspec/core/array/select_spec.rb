require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)
require File.expand_path('../shared/enumeratorize', __FILE__)
require File.expand_path('../shared/keep_if', __FILE__)

describe "Array#select" do
  pending do
    it_behaves_like :enumeratorize, :select
  end

  pending "returns a new array of elements for which block is true" do
    [1, 3, 4, 5, 6, 9].select { |i| i % ((i + 1) / 2) == 0}.should == [1, 4, 6]
  end

  it "does not return subclass instance on Array subclasses" do
    ArraySpecs::MyArray[1, 2, 3].select { true }.should be_kind_of(Array)
  end

  it "properly handles recursive arrays" do
    empty = ArraySpecs.empty_recursive_array
    empty.select { true }.should == empty
    empty.select { false }.should == []

    array = ArraySpecs.recursive_array
    array.select { true }.should == [1, 'two', 3.0, array, array, array, array, array]
    array.select { false }.should == []
  end
end

ruby_version_is "1.9" do
  describe "Array#select!" do
    it "returns nil if no changes were made in the array" do
      [1, 2, 3].select! { true }.should be_nil
    end

    pending do
      it_behaves_like :keep_if, :select!
    end
  end
end
