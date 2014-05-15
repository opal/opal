require 'spec_helper'
require 'template'

describe Template do
  describe ".paths" do
    it "should be an array of registered templates" do
      expect(Template.paths).to be_kind_of(Array)
    end
  end
end
