require 'spec_helper'

describe "Native exception" do
  it "handles messages for native exceptions" do
    exception = `new Error("native message")`
    exception.message.should == "native message"
  end
end
