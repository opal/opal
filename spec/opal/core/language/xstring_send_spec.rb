# backtick_javascript: false

describe "The x-string expression for send" do
  def `(command)
    "Linux x86_64" if command == "uname -a"
  end

  it "compiles as send if backtick_javascript is false" do
    `uname -a`.should == "Linux x86_64"
  end

  it "compiles as send with dstr if backtick_javascript is false" do
    `uname#{" "}-a`.should == "Linux x86_64"
  end
end
