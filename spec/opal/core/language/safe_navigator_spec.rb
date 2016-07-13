describe 'Safe navigator' do
  it "handles also null and undefined" do
    [`null`, `undefined`].each do |value|
      value&.unknown.should == nil
    end
  end
end
