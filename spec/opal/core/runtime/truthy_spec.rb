class Boolean
  def self_as_an_object
    self
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
  
  it "should evaluate to false if js `nil` is used" do
    input = `nil`
    is_false = false
    
    if input
      is_false = true
    end
    
    is_false.should be_true
  end
end
