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
