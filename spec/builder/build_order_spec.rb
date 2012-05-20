require File.expand_path('../../spec_helper', __FILE__)

describe "Builder#build_order" do
  before do
    @builder = Opal::Builder.new
  end

  it "should return the list of files in the right order to build" do
    @builder.build_order({ "a" => [], "b" => ["a"] }).should == ["a", "b"]
    @builder.build_order({ "c" => ["d"], "d" => [] }).should == ["d", "c"]
  end

  it "should ignore dependencies not in local files" do
    @builder.build_order({ "a" => ["b", "c"], "c" => [] }).should == ["c", "a"]
  end

  it "should include any files that don't get required" do
    @builder.build_order({ "a" => [], "b" => [], "c" => [] }).should == ["a", "b", "c"]
  end
end