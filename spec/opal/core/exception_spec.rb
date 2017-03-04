require 'spec_helper'

class ExceptionSubclassTest < Exception
  def custom_method
    42
  end
end

describe "Exception" do
  it "subclasses can have methods defined on them" do
    ExceptionSubclassTest.new.custom_method.should == 42
  end
end

describe "Native exception" do
  it "handles messages for native exceptions" do
    exception = `new Error("native message")`
    exception.message.should == "native message"
  end
end

# TODO: Delete when this code is added to the ruby spec
describe "Exception#to_s" do
  it "calls #to_s on the message" do
    message = mock("message")
    message.should_receive(:to_s).and_return("message").any_number_of_times
    ExceptionSpecs::Exceptional.new(message).to_s.should == "message"
  end
end

