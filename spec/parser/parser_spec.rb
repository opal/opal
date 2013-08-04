require 'spec_helper'

describe Opal::Parser do
  before { @parser = Opal::Parser.new }

  describe "extract parser options" do
    it "should return a hash" do
      @parser.extract_parser_options("").should be_kind_of(Hash)
    end

    it "extracts options when first line starts with '# opal:'" do
      @parser.extract_parser_options("# opal: foo, bar, baz").keys.should == [:foo, :bar, :baz]
    end

    it "converts any '-' in option name to '_'" do
      @parser.extract_parser_options("# opal: foo, bar-ba, baz-ba").keys.should == [:foo, :bar_ba, :baz_ba]
    end

    it "sets extracted options as true" do
      @parser.extract_parser_options("# opal: foo, bar").should == { :foo => true, :bar => true }
    end

    it "removes prefix of 'no-' or 'no_' from options" do
      @parser.extract_parser_options("# opal: no-foo, no_bar").keys.should == [:foo, :bar]
    end

    it "sets extracted no_ options as false" do
      @parser.extract_parser_options("# opal: no-foo, no_bar").should == { :foo => false, :bar => false }
    end

    it "can have a mixture of false and true options" do
      @parser.extract_parser_options("# opal: no-foo, bar").should == { :foo => false, :bar => true }
    end

    it "only extracts options on first line, if present" do
      @parser.extract_parser_options("# hello world").should == {}
      @parser.extract_parser_options("# hello world\n# opal: foo").should == {}
      @parser.extract_parser_options("# opal:    ").should == {}
    end
  end
end
