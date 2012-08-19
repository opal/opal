describe "Kernel#eql?" do
  it "returns true if obj and anObject are the same object." do
    o1 = Object.new
    o2 = Object.new
    o1.eql?(o1).should be_true
    o2.eql?(o2).should be_true
    o1.eql?(o2).should be_false
  end

  it "returns true if obj and anObject have the same value." do
    :hola.eql?(1).should be_false
    1.eql?(1).should be_true
    :hola.eql?(:hola).should be_true
  end
end