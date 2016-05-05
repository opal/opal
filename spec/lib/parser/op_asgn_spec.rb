require 'support/parser_helpers'

describe "Operator assignment statements on local variables" do
  next "Migrating to the 'parser' gem..."
  it "parses |= with a lvar on the left and parenthesized expr on the right" do
    # regression test; see GH issue 995
    asgn = [:lasgn, :var, [:int, 1]]
    opasgn = [:lasgn, :var, [:call, [:lvar, :var], :|, [:arglist, [:paren, [:int, 1]]]]]
    parsed('var = 1; var |= (1)').should == [:block, asgn, opasgn]
  end

  it "parses >>= with a lvar on the left and parenthesized expr on the right" do
    # regression test; see GH issue 995
    asgn = [:lasgn, :var, [:int, 1]]
    opasgn = [:lasgn, :var, [:call, [:lvar, :var], :>>, [:arglist, [:paren, [:int, 1]]]]]
    parsed('var = 1; var >>= (1)').should == [:block, asgn, opasgn]
  end
end
