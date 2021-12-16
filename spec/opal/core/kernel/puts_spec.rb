describe "IO#puts" do
  before :each do
    @before_separator = $/
    @io = IO.new(123)
    ScratchPad.record []
    def @io.write(str)
      ScratchPad << str
    end
  end

  after :each do
    ScratchPad.clear
    @io.close if @io
    suppress_warning {$/ = @before_separator}
  end

  it "writes just a newline when given no args" do
    @io.puts.should == nil
    ScratchPad.recorded.join("").should == "\n"
  end

  it "writes just a newline when given just a newline" do
    @io.puts("\n").should == nil
    ScratchPad.recorded.should == ["\n"]
  end

  it "writes empty string with a newline when given nil as an arg" do
    @io.puts(nil).should == nil
    ScratchPad.recorded.join("").should == "\n"
  end

  it "writes empty string with a newline when when given nil as multiple args" do
    @io.puts(nil, nil).should == nil
    ScratchPad.recorded.join("").should == "\n\n"
  end

  it "calls :to_s before writing non-string objects that don't respond to :to_ary" do
    object = mock('hola')
    object.should_receive(:to_s).and_return("hola")

    @io.puts(object).should == nil
    ScratchPad.recorded.join("").should == "hola\n"
  end

  # it "returns general object info if :to_s does not return a string" do
  #   object = mock('hola')
  #   object.should_receive(:to_s).and_return(false)
  #
  #   @io.puts(object).should == nil
  #   ScratchPad.recorded.join("").should == object.inspect.split(" ")[0] + ">\n"
  # end

  it "writes each arg if given several" do
    @io.puts(1, "two", 3).should == nil
    ScratchPad.recorded.join("").should == "1\ntwo\n3\n"
  end

  it "flattens a nested array before writing it" do
    @io.puts([1, 2, [3]]).should == nil
    ScratchPad.recorded.join("").should == "1\n2\n3\n"
  end

  it "writes nothing for an empty array" do
    @io.puts([]).should == nil
    ScratchPad.recorded.should == []
  end

  # it "writes [...] for a recursive array arg" do
  #   x = []
  #   x << 2 << x
  #   @io.puts(x).should == nil
  #   ScratchPad.recorded.join("").should == "2\n[...]\n"
  # end

  it "writes a newline after objects that do not end in newlines" do
    @io.puts(5).should == nil
    ScratchPad.recorded.join("").should == "5\n"
  end

  it "does not write a newline after objects that end in newlines" do
    @io.puts("5\n").should == nil
    ScratchPad.recorded.join("").should == "5\n"
  end

  it "ignores the $/ separator global" do
    suppress_warning {$/ = ":"}
    @io.puts(5).should == nil
    ScratchPad.recorded.join("").should == "5\n"
  end
end
