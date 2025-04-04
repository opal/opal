describe "defined?" do
  it "works with constants set to 0" do
    class TestingDefined
      RDONLY = 0
    end

    res = defined? TestingDefined::RDONLY
    res.should == 'constant'
  end
end
