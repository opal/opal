require 'spec_helper'

describe "Class#constants" do
  it "does not break on Object" do
    Object.constants.should be_kind_of(Array)
  end
end
