require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

ruby_version_is "1.9" do
  describe "Array.try_convert" do
    it "returns the argument if it's a Array" do
      x = Array.new
      Array.try_convert(x).should equal(x)
    end

    it "returns nil when the argument does not respond to #to_ary" do
      Array.try_convert(Object.new).should be_nil
    end
  end
end
