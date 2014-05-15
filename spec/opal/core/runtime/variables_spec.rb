require 'spec_helper'

describe "Mass assignment" do
  it "supports setting attributes on lhs" do
    object = Class.new { attr_accessor :foo, :bar }.new

    object.foo, object.bar = 100, 200

    expect(object.foo).to eq(100)
    expect(object.bar).to eq(200)
  end

  it "supports setting []= on lhs" do
    hash = {}
    hash[:foo], hash[:bar] = 3.142, 42

    expect(hash[:foo]).to eq(3.142)
    expect(hash[:bar]).to eq(42)
  end
end
