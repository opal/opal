describe 'Object#pretty_inspect' do
  it "doesn't throw due to the use of #<<" do
    expect("test".pretty_inspect).to eq %{"test"\n}
  end
end
