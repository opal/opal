require 'spec_helper'

describe "Parens" do
  it "can be used to group expressions" do
    expect(self.class; self.to_s; 42).to eq(42)
    expect(3.142).to eq(3.142)
    expect().to eq(nil)
  end

  it "generates code that contains the expression in precedence" do
    foo = 100
    expect((foo += 42) == 142).to eq(true)
  end
end
