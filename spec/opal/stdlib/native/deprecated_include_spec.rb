require 'native'

describe "Native inclusion" do
  it "is deprecated" do
    Native.should_receive(:warn).with("Including ::Native is deprecated. Please include Native::Wrapper instead.")
    Class.new { include Native }
  end
end
