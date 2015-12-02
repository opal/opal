require 'native'

describe "Native()" do
  it "should return nil for null or undefined" do
    Native(`null`).should be_nil
    Native(`undefined`).should be_nil
  end

  it "should return String" do
    Native(`""`).should be_an_instance_of String
  end

  it "should return Integer" do
    Native(`0`).should be_an_instance_of Number
  end

  it "should return Float" do
    Native(`0.01`).should be_an_instance_of Float
  end

  it "should return Array" do
    Native(`[]`).should be_an_instance_of Array
  end

  it "should return Native::Object" do
    Native(`{}`).instance_of?(Native::Object).should be_true
  end

  it "should return Array of String" do
    Native(`[""]`).first.should be_an_instance_of String
  end

  it "should return Array of Integer" do
    Native(`[0]`).first.should be_an_instance_of Number
  end

  it "should return Array of Float" do
    Native(`[0.01]`).first.should be_an_instance_of Float
  end

  it "should return Array of Array" do
    Native(`[[]]`).first.should be_an_instance_of Array
  end

  it "should return Array of Native::Object" do
    Native(`[{}]`).first.instance_of?(Native::Object).should be_true
  end

  it "should return Object with String" do
    Native(`{"key": ""}`)["key"].should be_an_instance_of String
  end

  it "should return Object with Integer" do
    Native(`{"key": 0}`)["key"].should be_an_instance_of Number
  end

  it "should return Object with Float" do
    Native(`{"key": 0.01}`)["key"].should be_an_instance_of Float
  end

  it "should return Object with Array" do
    Native(`{"key": []}`)["key"].should be_an_instance_of Array
  end

  it "should return Native::Object with Native::Object" do
    Native(`{"key": {}}`)["key"].instance_of?(Native::Object).should be_true
  end

  it "should return Proc" do
    Native(`function(){}`).should be_an_instance_of Proc
  end

  it "should return Proc that return String" do
    Native(`function(){return ""}`).call.should be_an_instance_of String
  end

  it "should return Proc that return Integer" do
    Native(`function(){return 0}`).call.should be_an_instance_of Integer
  end

  it "should return Proc that return Float" do
    Native(`function(){return 0.01}`).call.should be_an_instance_of Float
  end

  it "should return Proc that return Array" do
    Native(`function(){return []}`).call.should be_an_instance_of Array
  end

  it "should return Proc that return Native::Object" do
    Native(`function(){return {}}`).call.instance_of?(Native::Object).should be_true
  end
end
