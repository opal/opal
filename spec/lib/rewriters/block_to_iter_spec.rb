require 'lib/spec_helper'

describe Opal::Rewriters::BlockToIter do
  def s(type, *children)
    ::Parser::AST::Node.new(type, children)
  end

  let(:rewriter) { Opal::Rewriters::BlockToIter.new }

  let(:block_node) do
    # m { |arg1| 1 }
    s(:block,
      s(:send, nil, :m),
      s(:args, s(:arg, :arg1)),
      s(:int, 1)
    )
  end

  let(:iter_node) do
    s(:send, nil, :m,
      s(:iter, s(:args, s(:arg, :arg1)), s(:int, 1))
    )
  end

  it 'rewriters s(:block) to s(:iter)' do
    expect(rewriter.process(block_node)).to eq(iter_node)
  end
end
