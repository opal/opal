require File.expand_path('../../spec_helper', __FILE__)

describe "Builder#lib_name_for" do
  before do
    @builder = Opal::Builder.new
  end

  it "should remove initial 'lib/' prefix and file extension" do
    @builder.lib_name_for('lib/foo.rb').should == 'foo'
    @builder.lib_name_for('lib/foo/bar.rb').should == 'foo/bar'
    @builder.lib_name_for('lib/baz.js').should == 'baz'
  end

  it "should not remove prefixes other than 'lib/'" do
    @builder.lib_name_for('app.rb').should == 'app'
    @builder.lib_name_for('app/title.rb').should == 'app/title'
    @builder.lib_name_for('spec/spec_helper.rb').should == 'spec/spec_helper'
  end

  it "should remove the optional 'lib/opal/' prefix as well" do
    @builder.lib_name_for('lib/opal/json.rb').should == 'json'
    @builder.lib_name_for('lib/opal/json/parser.js').should == 'json/parser'
  end
end