require 'support/parser_helpers'

describe "Method calls using receiver[] syntax" do
  next "Migrating to the 'parser' gem..."
  it "accepts trailing &block argument" do
    # regression test; see GH issue #959
    splat = [:splat, [:call, nil, :args, [:arglist]]]
    block = [:block_pass, [:call, nil, :block, [:arglist]]]
    parsed("User[*args, &block]").should == [:call, [:const, :User], :[], [:arglist, splat, block]]
  end
end
