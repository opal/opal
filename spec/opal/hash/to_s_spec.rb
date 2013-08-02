require 'spec_helper'

describe "Hash#to_s" do
  it "handles recursive arrays without breaking" do
    h = {}
    h['foo'] = h
    h.to_s.should == '{"foo"=>{...}}'
  end
end
