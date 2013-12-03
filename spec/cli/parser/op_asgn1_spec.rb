require File.expand_path('../../spec_helper', __FILE__)

describe "op_asgn1" do
  it "returns s(:op_asgn1)" do
    parsed('self[:foo] += 1')[0].should == :op_asgn1
  end

  it "correctly assigns the receiver" do
    parsed("self[:foo] += 1")[1].should == [:self]
  end

  it "returns an arglist for args inside braces" do
    parsed("self[:foo] += 1")[2].should == [:arglist, [:sym, :foo]]
  end

  it "only uses the operator, not with '=' appended" do
    parsed("self[:foo] += 1")[3].should == '+'
  end

  it "uses a simple sexp, not an arglist" do
    parsed("self[:foo] += 1")[4].should == [:int, 1]
  end
end
