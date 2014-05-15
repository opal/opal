require 'json'

describe "Numeric#to_json" do
  it "returns a string representing the number" do
    expect(42.to_json).to eq("42")
    expect(3.142.to_json).to eq("3.142")
  end
end
