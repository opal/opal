require 'support/parser_helpers'

describe "The undef keyword" do
  it "returns s(:undef) with the argument as an s(:lit)" do
    expect(parsed("undef a")).to eq([:undef, [:sym, :a]])
  end

  it "appends multiple parts onto end of list" do
    expect(parsed("undef a, b")).to eq([:undef, [:sym, :a], [:sym, :b]])
  end

  it "can take symbols or fitems" do
    expect(parsed("undef :foo")).to eq([:undef, [:sym, :foo]])
  end
end
