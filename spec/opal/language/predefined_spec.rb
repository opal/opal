require 'spec_helper'

describe "Predefined global $!" do
  it "should be set to the new exception after a throwing rescue" do
    outer = StandardError.new 'outer'
    inner = StandardError.new 'inner'

    begin
      begin
        raise outer
      rescue
        $!.should == outer
        raise inner
      end
    rescue
      $!.should == inner
    end
    $!.should == nil
  end
end
