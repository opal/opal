class ExceptionSubclassSpec < Exception
  def nicer_message
    message + ", but don't worry son - you'll learn"
  end
end

describe "Exception subclasses" do
  it "should correctly report the class" do
    ExceptionSubclassSpec.new.class.should == ExceptionSubclassSpec
    Exception.new.class.should == Exception
  end

  it "should copy the subclasses methods onto instances" do
    msg = "it failed, but don't worry son - you'll learn"
    ExceptionSubclassSpec.new("it failed").nicer_message.should == msg
  end
end