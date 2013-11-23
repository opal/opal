require File.expand_path('../../spec_helper', __FILE__)

describe "Strings" do
  it "parses %[] strings" do
    opal_parse('%[]').should == [:str, '']
    opal_parse('%[foo]').should == [:str, 'foo']
  end
end
