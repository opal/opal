require 'opal'

module OpalSpecHelpers
  def parsed(source, file='(string)')
    Opal::Parser.new.parse(source, file)
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

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.include OpalSpecHelpers
end
