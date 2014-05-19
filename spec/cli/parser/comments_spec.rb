require 'support/parser_helpers'

describe "Multiline comments" do
  it "parses multiline comments and ignores them" do
    expect(parsed("=begin\nfoo\n=end\n100")).to eq([:int, 100])
  end

  it "raises an exception if not closed before end of file" do
    expect { parsed("=begin\nfoo\nbar") }.to raise_error(Exception, /embedded document meets end of file/)
  end
end
