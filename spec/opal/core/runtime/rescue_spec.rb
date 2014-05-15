require 'spec_helper'

class RescueReturningSpec
  def single
    begin
      raise "ERROR"
    rescue
      :foo
    end
  end

  def multiple
    begin
      raise "ERROR"
    rescue
      to_s
      :bar
    end
  end

  def empty_rescue
    begin
      raise "ERROR"
    rescue
    end
  end
end

describe "The rescue keyword" do
  it "returns last value of expression evaluated" do
    expect(RescueReturningSpec.new.single).to eq(:foo)
    expect(RescueReturningSpec.new.multiple).to eq(:bar)
  end

  it "returns nil if no expr given in rescue body" do
    expect(RescueReturningSpec.new.empty_rescue).to be_nil
  end
end
