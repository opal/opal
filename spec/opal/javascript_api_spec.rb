module JavaScriptAPIFixtures
  class A
  end

  class A::B
  end
end

require 'spec_helper'
require 'native'

describe "JavaScript API" do
  it "allows to acces scopes on `Opal` with dots (regression for #1418)" do
    `Opal.JavaScriptAPIFixtures.A.B`.should == JavaScriptAPIFixtures::A::B
  end

  describe 'Opal.exit' do
    def preserve_original_exit_handler
      original_exit_handler = `Opal.exit`
      yield
    ensure
      `Opal.exit = #{original_exit_handler}`
    end

    it 'should only receive numeric status' do
      preserve_original_exit_handler do
        status = nil
        `Opal.exit = function(received_status) {#{status = `received_status`}}`

        exit true
        status.should == 0
        status = nil

        exit false
        status.should == 1
        status = nil

        exit 'a'
        status.should == 0
        status = nil

        exit 1
        status.should == 1
        status = nil

        exit Object.new
        status.should == 0
        status = nil

        exit []
        status.should == 0
        status = nil

        exit -> {}
        status.should == 0
        status = nil
      end
    end
  end
end
