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
