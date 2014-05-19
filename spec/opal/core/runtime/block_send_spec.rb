require 'spec_helper'

class RuntimeOpalBlockSendSpec
  def simple
    42
  end

  def yielder(&block)
    yield 3.142
  end
end

describe "Opal.block_send()" do
  before do
    @obj = RuntimeOpalBlockSendSpec.new
  end

  it "calls receiver with given method" do
    expect(`Opal.block_send(#{@obj}, 'simple')`).to eq(42)
  end

  it "calls method with given block" do
    val = nil
    p = proc { |a| val = a }
    `Opal.block_send(#{@obj}, 'yielder', p)`
    expect(val).to eq(3.142)
  end
end
