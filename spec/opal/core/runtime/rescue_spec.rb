describe "The rescue keyword" do
  context 'JS::Error' do
    it 'handles raw js throws' do
      begin
        `throw { message: 'foo' }`
        nil
      rescue JS::Error => e
        e.JS[:message]
      end.should == 'foo'
    end

    it 'handles other Opal error' do
      begin
        raise 'bar'
      rescue JS::Error => e
        e.message
      end.should == 'bar'
    end

    it 'can be combined with other classes to catch js errors' do
      begin
        `throw { message: 'baz' }`
        nil
      rescue JS::Error, RuntimeError => e
        e.JS[:message]
      end.should == 'baz'
    end

    it 'can be combined with other classes to catch Opal errors' do
      begin
        raise 'quux'
      rescue JS::Error, RuntimeError => e
        e.message
      end.should == 'quux'
    end
  end
end
