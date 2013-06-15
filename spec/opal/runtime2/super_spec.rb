class OpalSuperDefineMethodSpec
  def foo
    "bar"
  end
end

describe "Super keyword" do
  it "works with methods defined with define_singleton_method" do
    a = OpalSuperDefineMethodSpec.new
    a.define_singleton_method(:foo) do
      super + " baz"
    end

    a.foo.should == "bar baz"
  end
end