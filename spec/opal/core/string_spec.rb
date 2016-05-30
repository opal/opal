require 'spec_helper'

describe "String" do
  it "handles contiguous parts correctly" do
    str = "a" "b"
    str.should == "ab"

    str2 = "d" "#{str}"
    str2.should == "dab"
  end

  it 'parses complex heredoc (pr #1363)' do
    str = <<'...end ruby23.y/module_eval...'

  def version
    23
  end

  def default_encoding
    Encoding::UTF_8
  end
...end ruby23.y/module_eval...

    str.should == "\n  def version\n    23\n  end\n\n  def default_encoding\n    Encoding::UTF_8\n  end\n"
  end
end

describe "String#tr" do
  it 'regression for: https://github.com/opal/opal/issues/1386' do
    'YWE/'.tr('+/', '-_').should == 'YWE_'
  end
end
