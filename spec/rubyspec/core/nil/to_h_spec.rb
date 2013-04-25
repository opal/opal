require File.expand_path('../../../spec_helper', __FILE__)

ruby_version_is "2.0" do
  describe "NilClass#to_h" do
    it "returns an empty hash" do
      nil.to_h.should == {}
      nil.to_h.default.should == nil
    end
  end
end
