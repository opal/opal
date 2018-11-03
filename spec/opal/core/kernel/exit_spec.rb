describe "Kernel#exit" do
  it "forwards the status code to Opal.exit(status)" do
    received_status { Kernel.exit }.should == 0
    received_status { Kernel.exit(0) }.should == 0
    received_status { Kernel.exit(1) }.should == 1
    received_status { Kernel.exit(2) }.should == 2
    received_status { Kernel.exit(123) }.should == 123
    received_status { Kernel.exit(true) }.should == 0
    received_status { Kernel.exit(false) }.should == 1
    received_status { Kernel.exit(Object.new) }.should == 0
    received_status { Kernel.exit([]) }.should == 0
    received_status { Kernel.exit(/123/) }.should == 0
  end

  def received_status
    received_status = nil
    original_exit = `Opal.exit`
    begin
      `Opal.exit = function(status) { #{received_status = `status`} }`
      yield
    ensure
      `Opal.exit = #{original_exit}`
    end
    received_status
  end
end
