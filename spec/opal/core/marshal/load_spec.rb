describe "Marshal.load" do
  it 'loads array with instance variable' do
    a = Marshal.load("\x04\bI[\bi\x06i\ai\b\x06:\n@ivari\x01{")
    a.should == [1, 2, 3]
    a.instance_variable_get(:@ivar).should == 123
  end
end
