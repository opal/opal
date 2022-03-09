module RewritersHelper
  module Common
    def s(type, *children)
      ::Opal::AST::Node.new(type, children)
    end

    def parse(source)
      buffer = Opal::Parser::SourceBuffer.new('(eval)')
      buffer.source = source
      parser = Opal::Parser.default_parser
      parser.parse(buffer)
    end

    # Parse, but drop the :top node
    def ast_of(source)
      parse(source).children.first
    end
  end

  module DSL
    def use_only_described_rewriter!
      around(:each) do |e|
        Opal::Rewriter.disable(except: described_class) { e.run }
      end
    end
  end

  include Common

  def self.included(klass)
    klass.extend(Common)
    klass.extend(DSL)
  end

  def rewriter
    described_class.new
  end

  def rewritten(ast = input)
    rewriter.process(ast)
  end

  alias rewrite rewritten
  alias processed rewritten

  def expect_rewritten(ast)
    expect(rewritten(ast))
  end

  def expect_no_rewriting_for(ast)
    expect_rewritten(ast).to eq(ast)
  end

  def parse_without_rewriting(source)
    Opal::Rewriter.disable { parse(source) }
  end
end

RSpec.shared_examples 'it rewrites source-to-source' do |from_source, to_source|
  it "rewrites source #{from_source} to source #{to_source}" do
    rewritten = parse(from_source)
    expected = parse(to_source)

    expect(rewritten).to eq(expected)
  end
end

RSpec.shared_examples 'it rewrites source-to-AST' do |from_source, to_ast|
  it "rewrites source #{from_source} to AST #{to_ast}" do
    rewritten = parse(from_source).children.first

    expect(rewritten).to eq(to_ast)
  end
end
