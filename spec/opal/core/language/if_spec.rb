describe "If statement" do
  it "returns when wrapped" do
    begin
      123

      if true
        foo while false

        5
      end
    end.should == 5
  end
end
