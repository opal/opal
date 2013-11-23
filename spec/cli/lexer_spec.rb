require File.expand_path('../spec_helper', __FILE__)
require 'opal/parser'

describe Opal::Lexer do
  it "sets correct line information for each token" do
    expect_lines("42").to eq([1])
    expect_lines("\n3.142").to eq([2])
    expect_lines("3.142\n42\n57").to eq([1, 2, 3])
  end

  it "increments the line count over multiple new lines" do
    expect_lines("1\n\n\n2").to eq([1, 4])
    expect_lines("\n\n\n3\n\n5\n\n").to eq([4, 6])
  end

  it "increments line numbers over =begin...=end blocks" do
    expect_lines("=begin\n=end\n1").to eq([3])
    expect_lines("=begin\nfoo\nbar\n=end\n42\n43").to eq([5, 6])
  end

  it "sets correct column for each token" do
    expect_columns("1").to eq([0])
    expect_columns("1;2; 3").to eq([0, 2, 5])
    expect_columns("    \t3").to eq([5])
  end

  it "sets the column to 0 on each new line" do
    expect_columns("1\n2\n\n\n3\n 4").to eq([0, 0, 0, 1])
  end

  it "sets column with regard to whitespace and other tokens before it" do
    expect_columns("true;  false;  self\n  ni;").to eq([0, 7, 15, 2])
  end

  def expect_lines(source)
    expect(parsed_nodes(source).map { |sexp| sexp.line })
  end

  def expect_columns(source)
    expect(parsed_nodes(source).map { |sexp| sexp.column })
  end

  def parsed_nodes(source)
    parsed = Opal::Parser.new.parse(source)
    parsed.type == :block ? parsed.children : [parsed]
  end
end
