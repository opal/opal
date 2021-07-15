class RespondToSpecs
  def foo
  end
end

describe "Kernel#respond_to?" do
  before :each do
    @a = RespondToSpecs.new
  end

  it "returns false if a method exists, but is marked with a '$$stub' property" do
    `#{@a}[Opal.s("$foo")][Opal.s.$$stub] = true`
    @a.respond_to?(:foo).should be_false
  end
end
