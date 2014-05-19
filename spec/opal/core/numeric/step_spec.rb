describe "Numeric#step" do
  before :each do
    ScratchPad.record []
    @prc = lambda { |x| ScratchPad << x }
  end

  it "defaults to step = 1" do
    1.step(5, &@prc)
    expect(ScratchPad.recorded).to eq([1, 2, 3, 4, 5])
  end
end
