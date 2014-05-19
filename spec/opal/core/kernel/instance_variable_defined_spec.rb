require 'spec_helper'

describe "Kernel#instance_variable_defined?" do
  before do
    @foo = :bar
  end

  it "returns true if ivar is defined" do
    expect(instance_variable_defined?(:@foo)).to be_true
  end

  it "returns false if ivar is not defined" do
    expect(instance_variable_defined?(:@this_does_not_exist)).to be_false
  end
end
