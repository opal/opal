# backtick_javascript: true

describe 'Safe navigator' do
  it "handles also null and undefined" do
    [`null`, `undefined`].each do |value|
      value&.unknown.should == nil
    end
  end

  it "calls a receiver exactly once" do
    def receiver
      @calls += 1
    end
    @calls = 0
    receiver&.itself.should == 1
    @calls = 0
    receiver&.itself{}.should == 1
  end
end
