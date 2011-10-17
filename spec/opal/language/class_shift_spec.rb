require File.expand_path('../../../spec_helper', __FILE__)

describe "'class <<' with a native object" do
  it "the 'self' value inside the block is the object itself" do
    obj = `{ "foo": "bar" }`
    class << obj
      `self.foo`
    end.should == "bar"

    obj2 = `function(){}`
    class << obj2
      `self`
    end.should == obj2
  end

  it "should define methods directly on the object with 'def self.x'" do
    obj = `{ "foo": "bar" }`
    class << obj
      def self.baz
        "biz"
      end
    end

    obj.baz.should == "biz"
  end

  it "should define methods on the objects' prototype with 'def x'" do
    obj = `function(){}`

    class << obj
      def foo
        "functional bar"
      end
    end

    a = `new obj()`
    a.foo.should == "functional bar"
  end
end

