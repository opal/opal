module RewritersHelper
  def s(type, *children)
    ::Opal::AST::Node.new(type, children)
  end

  def rewritten(ast)
    described_class.new.process(ast)
  end

  def expect_rewritten(ast)
    expect(rewritten(ast))
  end

  def expect_no_rewriting_for(ast)
    expect_rewritten(ast).to eq(ast)
  end

  def ast_of(source)
    buffer = Parser::Source::Buffer.new('(eval)')
    buffer.source = source
    parser = Opal::Parser.default_parser
    parser.parse(buffer)
  end
end

RSpec.shared_examples 'it rewrites source-to-source' do |from_source, to_source|
  it "rewrites source #{from_source} to source #{to_source}" do
    initial = ast_of(from_source)
    rewritten = self.rewritten(initial)
    expected = ast_of(to_source)

    expect(rewritten).to eq(expected)
  end
end

RSpec.shared_examples 'it rewrites source-to-AST' do |from_source, to_ast|
  it "rewrites source #{from_source} to AST #{to_ast}" do
    initial = ast_of(from_source)
    rewritten = self.rewritten(initial)

    expect(rewritten).to eq(to_ast)
  end
end
