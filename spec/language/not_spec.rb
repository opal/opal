require File.expand_path('../../spec_helper', __FILE__)

describe "The not keyword" do
  it "negates a `true' value" do
    (not true).should == false
    (not 'true').should == false
  end

  it "negates a `false' value" do
    (not false).should == true
    (not nil).should == true
  end

  it "accepts an argument" do
    lambda do
      not(true)
    end.call.should == false
  end
end

describe "The `!' keyword" do
  it "negates a `true' value" do
    (!true).should == false
    (!'true').should == false
  end

  it "negates a `false' value" do
    (!false).should == true
    (!nil).should == true
  end

  it "turns a truthful object into `true'" do
    (!!true).should == true
    (!!'true').should == true
  end

  it "turns a not truthful object into `false'" do
    (!!false).should == false
    (!!nil).should == false
  end
end
