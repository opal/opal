require File.expand_path('../../spec_helper', __FILE__)

class BuildSourceTest < Opal::Builder
  attr_reader :files

  def initialize
    @files = []
  end

  def build_file(base, source)
    @files << [base, source]
  end
end

build_source_dir = File.expand_path '../fixtures/build_source', __FILE__

describe "Builder#build_source" do
  it "should only build ruby sources" do
    Dir.chdir(build_source_dir) do
      b = BuildSourceTest.new
      b.build_source '.', 'foo'

      b.files.size.should == 2
      b.files.include?(['foo', 'a.rb']).should be_true
      b.files.include?(['foo', 'b.rb']).should be_true
    end
  end

  it "should recursively go into directories to find ruby sources" do
    Dir.chdir(build_source_dir) do
      b = BuildSourceTest.new
      b.build_source '.', 'bar'

      b.files.size.should == 3
      b.files.include?(['bar', 'a.rb']).should be_true
      b.files.include?(['bar/wow', 'b.rb']).should be_true
      b.files.include?(['bar/wow/cow', 'c.rb']).should be_true
    end
  end

  it "should be able to handle top level files" do
    Dir.chdir(build_source_dir) do
      b = BuildSourceTest.new
      b.build_source '.', 'adam.rb'
      b.files.should == [['.', 'adam.rb']]

      b2 = BuildSourceTest.new
      b2.build_source '.', 'charles.js'
      b2.files.should == []
    end
  end
end
