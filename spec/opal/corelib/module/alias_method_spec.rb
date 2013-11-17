class AliasMethodSpec
  module M
    def something
      3.142
    end

    alias_method :something_else, :something
  end

  include M

  def foo; 'foo'; end
  alias_method :bar, :foo
end

describe "Module#alias_method" do
  it "makes a copy of the method" do
    AliasMethodSpec.new.bar.should == 'foo'
  end

  describe "inside a module" do
    it "defined methods that get donated to a class when included" do
      obj = AliasMethodSpec.new
      obj.something.should == 3.142
      obj.something_else.should == 3.142
    end
  end
end
