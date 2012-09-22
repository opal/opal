class AliasMethodSpec
  def foo; 'foo'; end
  alias_method :bar, :foo
end

describe "Module#alias_method" do
  it "makes a copy of the method" do
    AliasMethodSpec.new.bar.should == 'foo'
  end
end