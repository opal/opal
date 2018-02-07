class Boolean
  def self_as_an_object
    self
  end
end

class JsNil
  def <(other)
    %x{
      return nil;
    }
  end
end

describe "Opal truthyness" do
  it "should evaluate to true using js `true` as an object" do
    if true.self_as_an_object
      called = true
    end

    called.should be_true
  end

  it "should evaluate to false using js `false` as an object" do
    if false.self_as_an_object
      called = true
    end

    called.should be_nil
  end

  it "should evaluate to false if js `nil` is used with an operator" do
    is_falsey = JsNil.new < 2 ? false : true

    is_falsey.should be_true
  end

  it "should consider false, nil, null, and undefined as not truthy" do
    called = nil
    [`false`, `nil`, `null`, `undefined`].each do |v|
      if v
        called = true
      end
    end

    called.should be_nil
  end

  it "should true as truthy" do
    if `true`
      called = true
    end

    called.should be_true
  end

  it "should handle logic operators correctly for false, nil, null, and undefined" do
    (`false` || `nil` || `null` || `undefined` || 1).should == 1
    [`false`, `nil`, `null`, `undefined`].each do |v|
      `#{1 && v} === #{v}`.should == true
    end
  end
end
