describe "Kernel#format" do
  it "should prepend '+' or '-' for numbers when flag '+' is specified" do
    format("%+d", 1).should == "+1"
    format("%+x", -1).should == "-1"
  end

  it "should prepend ' ' or '-' for numbers when flag ' ' is specified" do
    format("% d", 1).should == " 1"
    format("% x", 1).should == " 1"
    format("% x", -1).should ==  "-1"
  end

  it "should align left when flag '-' is specified" do
    format("%-5d", 123).should == "123  "
  end

  it "should prepend '0's when flag '0' is specified" do
    format("%010d", 10).should == "0000000010"
  end

  it "should output at least specified number of characters when width is specified" do
    format("%5d", 123).should == "  123"
    format("%+5d", 11).should == "  +11"
    format("%+-5d", 11).should == "+11  "
    format("%+05d", 11).should == "+0011"

    format("%0*x", 5, 10).should == "0000a"
  end

  describe "with precision" do
    it "should output specified number of digits for integers" do
      format("%10.5d", 1).should == "     00001"
      format("%+10.5x", 1).should == "    +00001"
    end

    it "should output specified number of significant digits for floats" do
      format("%10.5f", 1).should == "   1.00000"
      format("%10.5f", 10).should == "  10.00000"

      (format("%10.5e", 1) =~ /^1\.00000e\+0*0$/).should_not == nil
      (format("%10.5e", 10) =~ /^1\.00000e\+0*1$/).should_not == nil
    end

    it "should output at most specified number of characters for strings" do
      format("%10.2s", "foo").should == "        fo"

      format("%5.5s", "foo").should == "  foo"
      format("%5.5s", "foobar").should == "fooba"

      format("%.5s", "foobar").should == "fooba"
      format("%.*s", 5, "foobar").should == "fooba"
    end
  end

  it "should format a character with specifier 'c'" do
    format("%c", 97).should == "a"
    format("%c", 'a').should == "a"
  end

  it "should format a string with specifier 's'" do
    format("%s", "foo").should == "foo"
  end

  it "should format an object with specifier 'p'" do
    format("%p", "foo").should == "\"foo\""
  end

  it "should format an integer with specifier 'd' or 'i'" do
    format("%d", -1).should == "-1"
    format("%d", 3.1).should == "3"
  end

  it "should format an integer with specifier 'u'" do
    format("%u", -1).should == "-1"
  end

  it "should format an integer with specifier 'b', 'B', 'o', 'x' or 'X'" do
    format("%b", 10).should == "1010"
    format("%B", 10).should == "1010"
    format("%o", 10).should == "12"
    format("%x", 10).should == "a"
    format("%X", 10).should == "A"

    format("%x", -1).should == "-1"  # incompatible
  end

  it "should format a floating number with specifier 'f', 'e', 'E', 'g' or 'G'" do
    format("%f", 1.0).should == "1.000000"
    (format("%e", 1.0) =~ /^1\.000000e\+0*0$/).should_not == nil
    format("%g", 1.0).should == "1.00000"  # incompatible

    format("%f", 10.1).should == "10.100000"
    (format("%E", 10.1) =~ /^1\.010000E\+0*1$/).should_not == nil
    format("%g", 10.1).should == "10.1000"  # incompatible

    (format("%g", 1000000) =~ /^1.00000e\+0*6$/).should_not == nil
    (format("%G", 0.0000001) =~ /^1.00000E-0*7$/).should_not == nil
  end

  it "should format special floating number special values" do
    format("%f",  1.0/0).should == "Infinity"
    format("%f", -1.0/0).should == "-Infinity"
    format("%f",  0.0/0).should == "NaN"

    format("%E",  1.0/0).should == "INFINITY"
    format("%E", -1.0/0).should == "-INFINITY"
    format("%E",  0.0/0).should == "NAN"
  end

  it "should take specified index of argument if '$' is specified" do
    format("%d, %x, %o", 1, 2, 3).should == "1, 2, 3"
    format("%3$d, %2$x, %1$o", 1, 2, 3).should == "3, 2, 1"

    format("%1$d, %1$x, %1$o", 10).should == "10, a, 12"

    format("%1$*2$.*3$f", 1, 5, 2).should == " 1.00"
  end

  it "can output % by escaping it" do
    format("%%").should == "%"
  end
end
