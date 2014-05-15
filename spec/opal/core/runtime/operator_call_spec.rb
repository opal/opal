require 'spec_helper'

describe "Operator calls" do
  before { @obj = {:value => 10} }

  it "compiles as a normal send method call" do
    @obj[:value] += 15
    expect(@obj[:value]).to eq(25)

    @obj[:value] -= 23
    expect(@obj[:value]).to eq(2)
  end
end
