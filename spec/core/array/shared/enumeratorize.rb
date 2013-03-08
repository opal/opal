describe :enumeratorize, :shared => true do
  ruby_version_is '' ... '1.8.7' do
    it "raises a LocalJumpError if no block given" do
      lambda{ [1,2].send(@method) }.should raise_error(LocalJumpError)
    end
  end
  ruby_version_is '1.8.7' do
    it "returns an Enumerator if no block given" do
      [1,2].send(@method).should be_an_instance_of(enumerator_class)
    end
  end
end
