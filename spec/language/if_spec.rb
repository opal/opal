require File.expand_path('../../spec_helper', __FILE__)

describe "The if expression" do
  it "evaluates body if expression is true" do
    a = []
    if true
      a << 123
    end
    a.should == [123]
  end

  it "does not evaluate body if expression is false" do
    a = []
    if false
      a << 123
    end
    a.should == []
  end

  it "does not evaluate body if expression is empty" do
    a = []
    if ()
      a << 123
    end
    a.should == []
  end

  it "does not evaluate else body if expression is true" do
    a = []
    if true
      a << 123
    else
      a << 456
    end
    a.should == [123]
  end

  it "evaluates only else-body if expression is false" do
    a = []
    if false
      a << 123
    else
      a << 456
    end
    a.should == [456]
  end

  it "returns result of then-body evaluation if expression is true" do
    if true
      123
    end.should == 123
  end

  it "returns result of last statement in then-body if expression is true" do
    if true
      'foo'
      'bar'
      'baz'
    end.should == 'baz'
  end

  it "returns result of then-body evaluation if expression is true and else part is present" do
    if true
      123
    else
      456
    end.should == 123
  end

  it "returns result of else-body evaluation if expression is false" do
    if false
      123
    else
      456
    end.should == 456
  end

  it "returns nil if then-body is empty and expression is true" do
    if true
    end.should == nil
  end

  it "returns nil if then-body is empty, expression is true and else part is present" do
    if true
    else
      456
    end.should == nil
  end

  it "returns nil if then-body is empty, expression is true and else part is empty" do
    if true
    else
    end.should == nil
  end

  it "returns nil if else-body is empty and expression is false" do
    if false
      123
    else
    end.should == nil
  end

  it "returns nil is else-body is empty, expression is false and then-body is empty" do
    if false
    else
    end.should == nil
  end

  it "considers an expression with nil result as false" do
    if nil
      123
    else
      456
    end.should == 456
  end

  it "considers a non-nil and non-boolean object in expression result as true" do
    if 'x'
      123
    else
      456
    end.should == 123
  end

  it "considers a zero integer in expression result as true" do
    if 0
      123
    else
      456
    end.should == 123
  end

  it "allows starting else-body on the same line" do
    if false
      123
    else 456
    end.should == 456
  end

  it "evaluates subsequent elsif statements and execute body of first matching" do
    if false
      123
    elsif false
      234
    elsif true
      345
    elsif true
      456
    end.should == 345
  end

  it "evaluates else-body if no if/elsif statements match" do
    if false
      123
    elsif false
      234
    elsif false
      345
    else
      456
    end.should == 456
  end

  it "allows 'then' after expression when then-body is on the next line" do
    if true then
      123
    end.should == 123

    if true then ; 123; end.should == 123
  end

  it "allows then-body on the same line separated with 'then'" do
    if true then 123
    end.should == 123

    if true then 123; end.should == 123
  end

  it "returns nil when then-body on the same line separated by 'then' and expression is false" do
    if false then 123
    end.should == nil
  end

end

