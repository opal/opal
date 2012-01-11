require File.expand_path('../../../../spec_helper', __FILE__)

describe :regexp_match do
  it "returns nil if there is no match" do
    /xyz/.match("abxyc").should be_nil
  end

  it "returns nil if the object is nil" do
    /xyz/.match(nil).should be_nil
  end
end
