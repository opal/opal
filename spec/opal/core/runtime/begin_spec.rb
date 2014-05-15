require 'spec_helper'

describe "Begin block" do
  it "can be used as an expression" do
    foo = begin
            self.class
            200
          end

    expect(foo).to eq(200)

    expect(begin
      self.class
      42
    end).to eq(42)

    expect(begin
      3.142
    end).to eq(3.142)
  end

  it "can be used as part of an optional assignment" do
    count = 0
    foo = nil

    runner = proc do
      foo ||= begin
                count += 1
                count
              end
    end

    runner.call
    expect(foo).to eq(1)

    runner.call
    expect(foo).to eq(1)
  end
end
