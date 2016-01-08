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
end
