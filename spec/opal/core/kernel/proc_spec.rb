describe "Kernel#proc" do
  it "returns a Proc object" do
    expect(proc { true }.kind_of?(Proc)).to eq(true)
  end

  it "raises an ArgumentError when no block is given" do
    expect { proc }.to raise_error(ArgumentError)
  end
  
  it "is not a lambda" do
    expect(proc { true }.lambda?).to eq(false)
  end
end