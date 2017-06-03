describe "Marshal.load" do
  it 'loads array with instance variable' do
    a = Marshal.load("\x04\bI[\bi\x06i\ai\b\x06:\n@ivari\x01{")
    a.should == [1, 2, 3]
    a.instance_variable_get(:@ivar).should == 123
  end

  it 'loads a hash with a default value (hash_def)' do
    hash = Marshal.load("\x04\b}\x06i\x06i\a:\bdef")
    hash.should == { 1 => 2 }
    hash.default.should == :def
  end
end
