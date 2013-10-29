require 'spec_helper'

describe "Bridged Classes" do
  describe ".instance_methdods" do
    it "should report methods for class" do
      Array.instance_methods.should include(:shift)
    end

    it "should not include methods donated from Object/Kernel" do
      Array.instance_methods.should_not include(:class)
    end

    it "should not include methods donated from BasicObject" do
      Array.instance_methods.should_not include(:__send__)
      Array.instance_methods.should_not include(:send)
    end
  end
end
