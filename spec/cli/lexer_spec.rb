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

  describe "double-quoted strings" do
    it "escape backslashes in strings" do
      expect_parsed_string("\"foo\"").to eq("foo")
      expect_parsed_string("\"foo\\tbar\"").to eq("foo\tbar")
      expect_parsed_string("\"\\\"foo\"").to eq("\"foo")
    end

    it "removes new line in string directly after backslash" do
      expect_parsed_string("\"foo\\\nbar\"").to eq("foobar")
    end
  end

  describe "single-quoted strings" do
    it "do not support interpolation" do
      expect_parsed_string("'foo\#{self}'").to eq('foo#{self}')
      expect_parsed_string("'\#@bar'").to eq('#@bar')
      expect_parsed_string("'\#$baz'").to eq('#$baz')
    end

    it "do not escape backslashed characters" do
      expect_parsed_string("'foo'").to eq("foo")
      expect_parsed_string("'foo\\tbar'").to eq("foo\\tbar")
    end

    it "can escape \\ and \' characters" do
      expect_parsed_string("'a\\\\b\\'c'").to eq("a\\b'c")
    end
  end

  describe "escaped characters" do
    it "can parse octal escape sequences" do
      expect_parsed_string('"\\101\\103\\102"').to eq("ACB")
    end

    it "can parse hex escape sequences" do
      expect_parsed_string('"\\x61\\x63\\x62"').to eq('acb')
    end

    if defined?(::Encoding)
      it "can parse simple unicode sequences" do
        expect_parsed_string('"\\u1234"').to eq("\u1234")
      end
    end
  end

  describe "__END__ content in a source file" do
    it "ignores token and following content if at start of line and followed by newline" do
      expect_parsed("42\n__END__").to eq([:int, 42])
      expect_parsed("42\n__END__\nFred").to eq([:int, 42])
      expect_parsed(" __END__").to eq([:call, nil, :__END__, [:arglist]])
      expect_parsed("__END__ ").to eq([:call, nil, :__END__, [:arglist]])
      expect_parsed("__END__ 42").to eq([:call, nil, :__END__, [:arglist, [:int, 42]]])
    end

    it "adds any __END__ content to lexer.eof_content" do
      parser = Opal::Parser.new
      parser.parse("42")
      expect(parser.lexer.eof_content).to eq(nil)

      parser = Opal::Parser.new
      parser.parse("42\n__END__\nFord\nPerfect")
      expect(parser.lexer.eof_content).to eq("Ford\nPerfect")

      parser = Opal::Parser.new
      parser.parse("42\n__END__\n")
      expect(parser.lexer.eof_content).to eq("")
    end
  end

  describe "variable dereferencing ([])" do
    it "handles referencing correctly on local variables in scope" do
      expect_parsed("x = 0; x [0]").to eq([:block, [:lasgn, :x, [:int, 0]],
       [:call, [:lvar, :x], :[], [:arglist, [:int, 0]]]])
    end
  end
end
