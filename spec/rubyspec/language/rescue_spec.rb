require File.expand_path('../../spec_helper', __FILE__)
class SpecificExampleException < StandardError
end
class OtherCustomException < StandardError
end

def exception_list
  [SpecificExampleException, ZeroDivisionError]
end
describe "The rescue keyword" do
  before :each do
    ScratchPad.record []
  end

  it "can be used to handle a specific exception" do
    lambda do
      begin
        raise SpecificExampleException, "Raising this to be handled below"
      rescue SpecificExampleException
      end
    end.should_not raise_error
  end

  it "can capture the raised exception in a local variable" do
    begin
      raise SpecificExampleException, "some text"
    rescue SpecificExampleException => e
      e.message.should == "some text"
    end
  end

  it "can rescue multiple raised exceptions with a single rescue block" do
    lambda do
      [lambda{1/0}, lambda{raise SpecificExampleException}].each do |block|
        begin
          block.call
        rescue SpecificExampleException, ZeroDivisionError
        end
      end
    end.should_not raise_error
  end

  it "can rescue a splatted list of exceptions" do
    caught_it = false
    begin
      raise SpecificExampleException, "not important"
    rescue *exception_list
      caught_it = true
    end
    caught_it.should be_true
    caught = []
    lambda do
      [lambda{1/0}, lambda{raise SpecificExampleException}].each do |block|
        begin
          block.call
        rescue *exception_list
          caught << $!
        end
      end
    end.should_not raise_error
    caught.size.should == 2
    exception_list.each do |exception_class|
      caught.map{|e| e.class}.include?(exception_class).should be_true
    end
  end

  it "will only rescue the specified exceptions when doing a splat rescue" do
    lambda do
      begin
        raise OtherCustomException, "not rescued!"
      rescue *exception_list
      end
    end.should raise_error(OtherCustomException)
  end

  it "will execute an else block only if no exceptions were raised" do
    # begin
    #   ScratchPad << :one
    # rescue
    #   ScratchPad << :does_not_run
    # else
    #   ScratchPad << :two
    # end
    # ScratchPad.recorded.should == [:one, :two]
  end

  it "will not execute an else block if an exception was raised" do
    # begin
    #   ScratchPad << :one
    #   raise "an error occurred"
    # rescue
    #   ScratchPad << :two
    # else
    #   ScratchPad << :does_not_run
    # end
    # ScratchPad.recorded.should == [:one, :two]
  end

  it "will not rescue errors raised in an else block in the rescue block above it" do
    # lambda do
    #   begin
    #     ScratchPad << :one
    #   rescue Exception => e
    #     ScratchPad << :does_not_run
    #   else
    #     ScratchPad << :two
    #     raise SpecificExampleException, "an error from else"
    #   end
    # end.should raise_error(SpecificExampleException)
    # ScratchPad.recorded.should == [:one, :two]
  end

  ruby_version_is "1.9" do
    it "parses  'a += b rescue c' as 'a += (b rescue c)'" do
      a = 'a'
      c = 'c'
      # a += b rescue c
      a.should == 'ac'
    end
  end
end
