require File.expand_path('../../../spec_helper', __FILE__)

describe "nil values in opal" do
  it "should be equal to 'null'" do
    nil.should == `null`
    `null`.should == nil

    a = `null`
    a.should == nil

    @a = `null`
    @a.should == nil
  end

  it "should be equal to 'undefined'" do
    nil.should == `undefined`
    `undefined`.should == nil

    a = `undefined`
    a.should == nil

    @a = `undefined`
    @a.should == nil
  end

  it "should report the same class as 'null' and 'undefined'" do
    nil.class.should == NilClass
    `null`.class.should == NilClass
    `undefined`.class.should == NilClass
  end
end

