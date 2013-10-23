require 'spec_helper'

describe Opal::Compiler do
  it "parses operators before \n in command calls" do
    [:<<, :>>, :|, :^, :&, :<=>, :==, :===, :=~, :>, :>=, :<, :<=, :<<, :>>, :%, :**].each do |mid|
      opal_parse("self #{mid}\nself").should == [:call, [:self], mid, [:arglist, [:self]]]
    end
  end

  it "should parse simple ruby values" do
    eval('3.142').should == 3.142
    eval('123e1').should == 1230.0
    eval('123E+10').should == 1230000000000.0
    eval('123e-9').should == 0.000000123
    eval('false').should == false
    eval('true').should == true
    eval('nil').should == nil
  end

  it "should parse ruby strings" do
    eval('"hello world"').should == "hello world"
    eval('"hello #{100}"').should == "hello 100"
  end

  it "should parse method calls" do
    eval("[1, 2, 3, 4].inspect").should == "[1, 2, 3, 4]"
    eval("[1, 2, 3, 4].map { |a| a + 42 }").should == [43, 44, 45, 46]
  end

  it "should parse constant lookups" do
    eval("Object").should == Object
    eval("Array").should == Array
    eval("Opal::Compiler").should == Opal::Compiler
  end

  it "should parse class and module definitions" do
    eval("class ParserModuleDefinition; end")
    eval <<-STR
      class ParserClassDefinition
        CONSTANT = 500

        def foo
          500
        end

        def self.bar
          42
        end
      end
    STR

    ParserClassDefinition.bar.should == 42
    ParserClassDefinition.new.foo.should == 500
  end

  describe "multiline comments" do
    it "parses multiline comments and ignores them" do
      opal_parse("=begin\nfoo\n=end\n100").should == [:int, 100]
    end

    it "raises an exception if not closed before end of file" do
      lambda { opal_parse("=begin\nfoo\nbar") }.should raise_error(Exception, /embedded document meets end of file/)
    end

  end
end
