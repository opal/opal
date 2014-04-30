module ParserHelpers
  def parsed(source, file='(string)')
    Opal::Parser.new.parse(source, file)
  end

  def expect_parsed(source)
    expect(parsed(source))
  end

  def expect_parsed_string(source)
    expect(parsed(source)[1])
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

if defined? RSpec
  RSpec.configure do |config|
    config.include ParserHelpers
  end
else
  include ParserHelpers
end

