describe "Opal.eval()" do
  it "evaluates ruby code by compiling it to javascript and running" do
    expect(`Opal.eval("'foo'.class")`).to eq(String)
  end
end
