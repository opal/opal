describe 'rescue' do
  it 'wraps a try{}catch{} to a function when there is a method call on returning value' do
    begin
      1 + 1
    rescue
    end.should == 2
  end

  it 'explicitely adds return to the rescue part when there is ensure statement' do
    begin
      1 + 1
    rescue
      3
    ensure
      4
    end.should == 2
  end
end
