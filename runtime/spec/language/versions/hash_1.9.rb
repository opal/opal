require File.expand_path('../../../spec_helper', __FILE__)

describe "Hash literal" do
  describe "new-style hash syntax" do
    it "constructs a new hash with the given elements" do
      {foo: 123}.should == {:foo => 123}
      {rbx: :cool, specs: 'fail_sometimes'}.should == {:rbx => :cool, :specs => 'fail_sometimes'}
    end

    it "ignores a hanging comma" do
      {foo: 123,}.should == {:foo => 123}
      {rbx: :cool, specs: 'fail_sometimes',}.should == {:rbx => :cool, :specs => 'fail_sometimes'}
    end

    it "can mix and match syntax styles" do
      {rbx: :cool, :specs => 'fail_sometimes'}.should == {:rbx => :cool, :specs => 'fail_sometimes'}
      {'rbx' => :cool, specs: 'fail_sometimes'}.should == {'rbx' => :cool, :specs => 'fail_sometimes'}
    end
  end
end
