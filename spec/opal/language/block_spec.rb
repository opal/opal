require 'spec_helper'

describe "Blocks" do
  it "accept default arguments" do
    proc { |a, b = 100| [a, b] }.call(:foo, :bar).should == [:foo, :bar]
    proc { |a, b = 100| [a, b] }.call(:foo).should == [:foo, 100]
  end
end
