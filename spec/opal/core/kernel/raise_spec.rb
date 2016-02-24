describe "Kernel#raise" do
  # ruby-specs test most of this, but ruby-specs won't differentiate between nil and undefined
  it "raises messages without exceptions" do
    lambda { raise Exception }.should raise_error(Exception)
    ex = nil
    begin
      raise Exception
    rescue Exception => e
      ex = e
    end
    ex.to_s.should == 'Exception'
  end
end
