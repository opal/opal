# backtick_javascript: true

describe "Opal.eval()" do
  it "evaluates ruby code by compiling it to javascript and running" do
    `Opal['eval']("'foo'.class")`.should == String
  end
end

describe "Kernel#eval" do
  module EvalSpecs
    CONST = :outer

    module Nested
      def self.lookup_const
        eval('CONST')
      end

      def self.nesting
        eval('Module.nesting')
      end
    end
  end

  it "looks a constant up through the whole lexical nesting" do
    EvalSpecs::Nested.lookup_const.should == :outer
  end

  it "keeps the nesting of the calling scope" do
    EvalSpecs::Nested.nesting.should == [EvalSpecs::Nested, EvalSpecs]
  end

  it "falls back to the receiver's class when there is no enclosing nesting" do
    # Under mspec the example block runs inside MSpecEnv rather than at the
    # real toplevel, so the nesting here comes from self, not from a module.
    eval('Module.nesting').should == [MSpecEnv]
  end

  it "resolves a scoped constant" do
    eval('EvalSpecs::CONST').should == :outer
  end
end
