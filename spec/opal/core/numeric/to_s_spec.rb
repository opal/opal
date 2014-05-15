describe "Fixnum#to_s when given a base" do
  it "returns self converted to a String in the given base" do
    expect(12345.to_s(2)).to eq("11000000111001")
    expect(12345.to_s(8)).to eq("30071")
    expect(12345.to_s(10)).to eq("12345")
    expect(12345.to_s(16)).to eq("3039")
    expect(95.to_s(16)).to eq("5f")
    expect(12345.to_s(36)).to eq("9ix")
  end

  it "raises an ArgumentError if the base is less than 2 or higher than 36" do
    expect { 123.to_s(-1) }.to raise_error(ArgumentError)
    expect { 123.to_s(0)  }.to raise_error(ArgumentError)
    expect { 123.to_s(1)  }.to raise_error(ArgumentError)
    expect { 123.to_s(37) }.to raise_error(ArgumentError)
  end
end

describe "Numeric#to_s when no base given" do
  it "returns self converted to a String using base 10" do
    expect(255.to_s).to eq('255')
    expect(3.to_s).to eq('3')
    expect(0.to_s).to eq('0')
    expect((-9002).to_s).to eq('-9002')
  end
end
