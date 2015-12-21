require 'strscan'

describe "StringScanner#scan" do
  context "when the regex has multiple alternatives" do
    it "still anchors to the beginning of the remaining text" do
      # regression test; see GH issue 1074
      scanner = StringScanner.new("10\nb = `2E-16`")
      scanner.scan(/[\d_]+\.[\d_]+\b|[\d_]+(\.[\d_]+)?[eE][-+]?[\d_]+\b/).should be_nil
    end
  end
end
