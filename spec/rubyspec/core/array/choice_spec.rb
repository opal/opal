require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Array#choice" do
  ruby_version_is "1.8.7"..."1.9" do
    it "returns a value from the array" do
      [4].choice.should eql(4)
    end

    it "returns a distribution of results" do
      source = [0,1,2,3,4]
      choices = ArraySpecs::SampleRange.collect { |el| source.choice }
      choices.uniq.sort.should == source
    end

    it "returns nil for empty arrays" do
      [].choice.should be_nil
    end
  end
end
