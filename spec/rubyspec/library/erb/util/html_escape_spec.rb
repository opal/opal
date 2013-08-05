require 'erb'
require File.expand_path('../../../../spec_helper', __FILE__)

describe "ERB::Util.html_escape" do
  it "escape (& < > \" ') to (&amp; &lt; &gt; &quot; &#39;)" do
    input = '& < > " \''
    expected = '&amp; &lt; &gt; &quot; &#39;'
    ERB::Util.html_escape(input).should == expected
  end
end
