require File.expand_path('../../spec_helper', __FILE__)

describe "Builder#output_path" do
  describe "without an output dir" do
    it "should return base and source joined with .js extname" do
      b = Opal::Builder.new '', :output => ''
      b.output_path('.', 'foo.rb').should == 'foo.js'
      b.output_path('lib', 'foo.rb').should == 'lib/foo.js'
      b.output_path('lib/foo', 'bar.rb').should == 'lib/foo/bar.js'
    end 

    it "supports '.' as output dir" do
      b = Opal::Builder.new '', :output => '.'
      b.output_path('.', 'foo.rb').should == 'foo.js'
      b.output_path('lib', 'foo.rb').should == 'lib/foo.js'
      b.output_path('lib/foo', 'bar.rb').should == 'lib/foo/bar.js'
    end

    it "supports nil as output dir" do
      b = Opal::Builder.new '', :output => nil
      b.output_path('.', 'foo.rb').should == 'foo.js'
      b.output_path('lib', 'foo.rb').should == 'lib/foo.js'
      b.output_path('lib/foo', 'bar.rb').should == 'lib/foo/bar.js'
    end

    it "supports false as output dir" do
      b = Opal::Builder.new '', :output => false
      b.output_path('.', 'foo.rb').should == 'foo.js'
      b.output_path('lib', 'foo.rb').should == 'lib/foo.js'
      b.output_path('lib/foo', 'bar.rb').should == 'lib/foo/bar.js'
    end
  end

  describe "with an output dir" do
    it "should return output dir joined with source when base is '.'" do
      b = Opal::Builder.new '', :output => 'build'

      b.output_path('.', 'foo.rb').should == 'build/foo.js'
      b.output_path('.', 'bar.rb').should == 'build/bar.js'
    end

    it "returns the parts joined but with first part of base removed" do
      b = Opal::Builder.new '', :output => 'build'

      b.output_path('lib', 'foo.rb').should == 'build/foo.js'
      b.output_path('lib/foo', 'bar.rb').should == 'build/foo/bar.js'
      b.output_path('lib/foo/bar', 'baz.rb').should == 'build/foo/bar/baz.js'
    end
  end
end
