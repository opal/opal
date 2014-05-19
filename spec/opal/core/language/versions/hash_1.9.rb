describe "Hash literal" do
  describe "new-style hash syntax" do
    it "constructs a new hash with the given elements" do
      expect({foo: 123}).to eq({:foo => 123})
      expect({rbx: :cool, specs: 'fail_sometimes'}).to eq({:rbx => :cool, :specs => 'fail_sometimes'})
    end

    it "ignores a hanging comma" do
      expect({foo: 123,}).to eq({:foo => 123})
      expect({rbx: :cool, specs: 'fail_sometimes',}).to eq({:rbx => :cool, :specs => 'fail_sometimes'})
    end

    it "can mix and match syntax styles" do
      expect({rbx: :cool, :specs => 'fail_sometimes'}).to eq({:rbx => :cool, :specs => 'fail_sometimes'})
      expect({'rbx' => :cool, specs: 'fail_sometimes'}).to eq({'rbx' => :cool, :specs => 'fail_sometimes'})
    end
  end
end
