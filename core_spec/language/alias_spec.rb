class AliasObject
  attr :foo
  attr_reader :baz
  attr_accessor :baz

  def prep; @foo = 3; @bar = 4; end
  def value; 5; end
  def false_value; 6; end
end

describe "The alias keyword" do
  before(:each) do
    @obj = AliasObject.new
    @meta = class << @obj;self;end
  end

  it "creates a new name for an existing method" do
    @meta.class_eval do
      alias __value value
    end
    @obj.__value.should == 5
  end
end