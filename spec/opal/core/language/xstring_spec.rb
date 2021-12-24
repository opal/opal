describe "The x-string expression" do
  it "works with multiline, case and assignment" do
    a = case 1
        when 1
          %x{
            var b = 5;
            return b;
          }
        end
    
    a.should == 5
  end
end
