require File.expand_path('../../spec_helper', __FILE__)

describe "Heredocs" do

  it "parses as a s(:str)" do
    opal_parse("a = <<-FOO\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "allows start marker to be wrapped in quotes" do
    opal_parse("a = <<-'FOO'\nbar\nFOO")[2].should == [:str, "bar\n"]
    opal_parse("a = <<-\"FOO\"\nbar\nFOO")[2].should == [:str, "bar\n"]
  end

  it "does not parse EOS unless beginning of line" do
    opal_parse("<<-FOO\ncontentFOO\nFOO").should == [:str, "contentFOO\n"]
  end

  it "does not parse EOS unless end of line" do
    opal_parse("<<-FOO\nsome FOO content\nFOO").should == [:str, "some FOO content\n"]
  end

  it "parses postfix code as if it appeared after heredoc" do
    opal_parse("<<-FOO.class\ncode\nFOO").should == [:call, [:str, "code\n"], :class, [:arglist]]
    opal_parse("bar(<<-FOO, 1, 2, 3)\ncode\nFOO").should == [:call, nil, :bar,
                                                              [:arglist, [:str, "code\n"],
                                                                         [:int, 1],
                                                                         [:int, 2],
                                                                         [:int, 3]]]
  end
end
