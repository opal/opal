require "spec_helper"

describe "Strings" do
  it "parses %[] strings" do
    opal_parse('%[]').should == [:str, '']
    opal_parse('%[foo]').should == [:str, 'foo']
  end
end
