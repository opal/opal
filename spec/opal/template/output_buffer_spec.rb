require 'spec_helper'
require 'template'

describe Template::OutputBuffer do
  before do
    @buf = Template::OutputBuffer.new
  end

  it "collects content that can be concatenated together" do
    @buf.append "foo"
    @buf.append= "bar"
    @buf.append "baz"
    @buf.join.should == "foobarbaz"
  end

  describe "#capture" do
    it "replaces the buffer temporarily" do
      @buf.append "foo"
      @buf.capture { @buf.append "bar" }
      @buf.append "baz"
      @buf.join.should == "foobaz"
    end

    it "returns all buffered output for duration of block" do
      @buf.append "foo"
      out = @buf.capture { @buf.append "woosh"; @buf.append "kapow" }
      @buf.append "baz"
      out.should == "wooshkapow"
    end

    it "passes any arguments to block" do
      @buf.capture("adam", "beynon") do |first, last|
        @buf.append "hello #{first} #{last}"
      end.should == "hello adam beynon"
    end
  end
end
