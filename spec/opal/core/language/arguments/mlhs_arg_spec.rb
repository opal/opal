# regression test
describe 'mlhs argument' do
  context 'when pased value is falsey in JS' do
    it 'still returns it' do
      p = ->((a)){ a }
      p.call(false).should == false
      p.call("").should == ""
      p.call(0).should == 0
    end
  end

  context 'when passed value == null' do
    it 'replaces it with nil' do
      p = ->((a)){ a }
      p.call([`undefined`]).should == nil
      p.call([`null`]).should == nil
    end
  end
end
