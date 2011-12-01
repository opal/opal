require File.expand_path('../../spec_helper', __FILE__)

describe "An ensure block inside a begin block" do
  before :each do
    ScratchPad.record []
  end

  it "is executed when an exception is raised in it's corresponding begin block" do
    begin
      lambda {
        begin
          ScratchPad << :begin
          raise "An exception occured!"
        ensure
          ScratchPad << :ensure
        end
      }.should raise_error(RuntimeError)

      ScratchPad.recorded.should == [:begin, :ensure]
    end
  end

  it "is executed when an exception is raised and rescued in it's corresponding begin block" do
    begin
      begin
        ScratchPad << :begin
        raise "An exception occured!"
      rescue
        ScratchPad << :rescue
      ensure
        ScratchPad << :ensure
      end

      ScratchPad.recorded.should == [:begin, :rescue, :ensure]
    end
  end

  it "is executed when nothing is raised or thrown in it's corresponding begin block" do
    begin
      ScratchPad << :begin
    rescue
      ScratchPad << :rescue
    ensure
      ScratchPad << :ensure
    end

    ScratchPad.recorded.should == [:begin, :ensure]
  end

  it "has no return value" do
    begin
      :begin
    ensure
      :ensure
    end.should == :begin
  end
end
