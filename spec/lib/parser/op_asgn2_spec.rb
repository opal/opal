require 'support/parser_helpers'

describe "op_asgn2" do
  it "returns s(:op_asgn2)" do
    parsed('self.foo += 1')[0].should == :op_asgn2
  end

  it "correctly assigns the receiver" do
    parsed("self.foo += 1")[1].should == [:self]
  end

  it "appends '=' onto the identifier in the sexp" do
    parsed("self.foo += 1")[2].should == :foo=
  end

  it "only uses the operator, not with '=' appended" do
    parsed("self.foo += 1")[3].should == :+
  end

  it "uses a simple sexp, not an arglist" do
    parsed("self.foo += 1")[4].should == [:int, 1]
  end
end
