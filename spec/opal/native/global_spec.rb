require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../fixtures/classes', __FILE__)

describe "Native#global" do
  it "is an instance of Native" do
    (Native === Native.global).should be_true
  end

  it "wraps Opal.global" do
    (Native.global == Native.new(`Opal.global`)).should be_true
  end
end

describe "$global" do
  it "is an alias of Native.global" do
    ($global == Native.global).should be_true
  end
end

describe "$window" do
  it "is an alias of Native.global" do
    ($window == Native.global).should be_true
  end
end
