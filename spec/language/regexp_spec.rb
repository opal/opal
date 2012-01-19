require File.expand_path('../../spec_helper', __FILE__)

describe "Literal Regexps" do
  it "yields a Regexp" do
    /Hello/.should be_kind_of(Regexp)
  end
end
