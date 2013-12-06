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
end
