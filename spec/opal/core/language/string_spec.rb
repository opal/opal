describe "Ruby character strings" do
  it "are produced from character shortcuts" do
    ?z.should == 'z'
  end

  it "should parse string into %[]" do 
    %[foo].should == "foo"
    %|bar|.should == "bar"
    %'baz'.should == "baz"
  end

  it "interpolate string" do 
    a = 1
    %[#{a}23].should == "123"
  end

  it "should not process escape characters in single-quoted heredocs" do
    s = <<'EOD'
      hey\now\brown\cow
    EOD
    s.strip.should == 'hey\now\brown\cow'
  end

  it "should ignore single-quote escapes in single-quoted heredocs" do
    s = <<'EOD'
      they\'re greeeeaaat!
    EOD
    s.strip.should == 'they\\\'re greeeeaaat!'
  end

  it "should process escape characters in double quoted heredocs" do
    s = <<"EOD"
      hey\now\brown\cow
    EOD
    s.strip.should == "hey\now\brown\cow"
  end

  it "should treat bare-word heredoc identifiers as double-quoted" do
    s = <<EOD
      hey\now\brown\cow
    EOD
    s.strip.should == "hey\now\brown\cow"
  end
end
