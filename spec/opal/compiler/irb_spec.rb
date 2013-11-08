require 'spec_helper'
require 'native'

describe Opal::Compiler do
  describe "irb parser option" do
    before do
      @compiler = Opal::Compiler.new
    end

    it "creates Opal.irb_vars if it does not exist" do
      $global["Opal"].irb_vars = nil
      eval_js(@compiler.compile "nil", :irb => true)

      ($global["Opal"].irb_vars == nil).should be_false
    end

    it "does not create Opal.irb_vars if :irb option not passed" do
      $global["Opal"].irb_vars = nil
      eval_js(@compiler.compile "nil")

      ($global["Opal"].irb_vars == nil).should be_true
    end

    it "sets each s(:lasgn) in the top level onto irb_vars" do
      eval_js @compiler.compile "foo = 42", :irb => true
      $global["Opal"].irb_vars.foo.should == 42
    end

    it "gets each s(:lvar) in the top level from irb_vars" do
      eval_js @compiler.compile "foo = 3.142; bar = foo", :irb => true
      $global["Opal"].irb_vars.bar.should == 3.142
    end

    it "persists local vars between parses" do
      eval_js @compiler.compile "foo = 'hello world'", :irb => true
      eval_js @compiler.compile "bar = foo.upcase", :irb => true
      $global["Opal"].irb_vars.bar.should == "HELLO WORLD"
    end

    it "can still call top level methods" do
      eval_js(@compiler.compile("to_s", :irb => true)).should == "main"
    end
  end
end
