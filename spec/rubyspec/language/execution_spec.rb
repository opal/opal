require File.expand_path('../../spec_helper', __FILE__)

describe "``" do
  pending "returns the output of the executed sub-process" do
    ip = 'world'
    # `echo disc #{ip}`.should == "disc world\n"
  end
end

describe "%x" do
  pending "is the same as ``" do
    ip = 'world'
    # %x(echo disc #{ip}).should == "disc world\n"
  end
end
