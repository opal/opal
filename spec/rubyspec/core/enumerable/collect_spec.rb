require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Enumerable#collect" do
  before :each do
    ScratchPad.record []
  end

  it "returns a new array with the results of passing each element to block" do
    entries = [0, 1, 3, 4, 5, 6]
    numerous = EnumerableSpecs::Numerous.new(*entries)
    numerous.collect { |i| i % 2 }.should == [0, 1, 1, 0, 1, 0]
    numerous.collect { |i| i }.should == entries
  end

  ruby_version_is ""..."1.9" do
    it "gathers whole arrays as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      multi.send(@method) {|e| e}.should == [[1,2],[3,4,5],[6,7,8,9]]
    end

    it "returns to_a when no block given" do
      EnumerableSpecs::Numerous.new.send(@method).should == [2, 5, 3, 6, 1, 4]
    end
  end

  ruby_version_is "1.9" do
    it "gathers initial args as elements when each yields multiple" do
      multi = EnumerableSpecs::YieldsMulti.new
      multi.collect {|e| e}.should == [1, 3, 6]
    end

    it "returns an enumerator when no block given" do
      enum = EnumerableSpecs::Numerous.new.collect
      enum.should be_an_instance_of(enumerator_class)
      enum.each { |i| -i }.should == [-2, -5, -3, -6, -1, -4]
    end
  end
end
