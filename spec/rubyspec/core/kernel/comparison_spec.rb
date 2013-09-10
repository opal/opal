require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is "1.9" do
  describe "Kernel#<=>" do
    it "returns 0 if self" do
      obj = Object.new
      (obj.<=>(obj)).should == 0
    end

    it "returns nil if self is not == to the argument" do
      obj = Object.new
      (obj.<=>(3.14)).should be_nil
    end
  end
end
