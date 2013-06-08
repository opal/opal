require 'spec_helper'

describe Opal::Parser do
  describe "irb parser option" do
    before do
      @parser = Opal::Parser.new
    end

    it "creates Opal.irb_vars if it does not exist" do
      $global["Opal"].irb_vars = nil
      opal_eval_compiled(@parser.parse "nil", :irb => true)

      ($global["Opal"].irb_vars == nil).should be_false
    end

    it "does not create Opal.irb_vars if :irb option not passed" do
      $global["Opal"].irb_vars = nil
      opal_eval_compiled(@parser.parse "nil")

      ($global["Opal"].irb_vars == nil).should be_true
    end

    it "sets each s(:lasgn) in the top level onto irb_vars" do
      opal_eval_compiled @parser.parse "foo = 42", :irb => true
      $global["Opal"].irb_vars.foo.should == 42
    end

    it "gets each s(:lvar) in the top level from irb_vars" do
      opal_eval_compiled @parser.parse "foo = 3.142; bar = foo", :irb => true
      $global["Opal"].irb_vars.bar.should == 3.142
    end

    it "persists local vars between parses" do
      opal_eval_compiled @parser.parse "foo = 'hello world'", :irb => true
      opal_eval_compiled @parser.parse "bar = foo.upcase", :irb => true
      $global["Opal"].irb_vars.bar.should == "HELLO WORLD"
    end
  end
end
