# backtick_javascript: true

describe "Case statement" do
  it "works with JS object-wrapped values" do
    a = false
    objwr = `new String("abc")`

    case objwr
    when "abc"
      a = true
    end

    a.should == true
  end
end
