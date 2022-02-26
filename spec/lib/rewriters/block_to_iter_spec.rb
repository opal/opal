require 'lib/spec_helper'
require 'support/rewriters_helper'

RSpec.describe Opal::Rewriters::BlockToIter do
  include RewritersHelper

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
    expect(rewritten(block_node)).to eq(iter_node)
  end
end
