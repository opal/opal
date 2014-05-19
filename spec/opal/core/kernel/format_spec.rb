describe "Kernel#format" do
  it "should prepend '+' or '-' for numbers when flag '+' is specified" do
    expect(format("%+d", 1)).to eq("+1")
    expect(format("%+x", -1)).to eq("-1")
  end

  it "should prepend ' ' or '-' for numbers when flag ' ' is specified" do
    expect(format("% d", 1)).to eq(" 1")
    expect(format("% x", 1)).to eq(" 1")
    expect(format("% x", -1)).to eq("-1")
  end

  it "should align left when flag '-' is specified" do
    expect(format("%-5d", 123)).to eq("123  ")
  end

  it "should prepend '0's when flag '0' is specified" do
    expect(format("%010d", 10)).to eq("0000000010")
  end

  it "should output at least specified number of characters when width is specified" do
    expect(format("%5d", 123)).to eq("  123")
    expect(format("%+5d", 11)).to eq("  +11")
    expect(format("%+-5d", 11)).to eq("+11  ")
    expect(format("%+05d", 11)).to eq("+0011")

    expect(format("%0*x", 5, 10)).to eq("0000a")
  end

  describe "with precision" do
    it "should output specified number of digits for integers" do
      expect(format("%10.5d", 1)).to eq("     00001")
      expect(format("%+10.5x", 1)).to eq("    +00001")
    end

    it "should output specified number of significant digits for floats" do
      expect(format("%10.5f", 1)).to eq("   1.00000")
      expect(format("%10.5f", 10)).to eq("  10.00000")

      expect(format("%10.5e", 1) =~ /^1\.00000e\+0*0$/).not_to eq(nil)
      expect(format("%10.5e", 10) =~ /^1\.00000e\+0*1$/).not_to eq(nil)
    end

    it "should output at most specified number of characters for strings" do
      expect(format("%10.2s", "foo")).to eq("        fo")

      expect(format("%5.5s", "foo")).to eq("  foo")
      expect(format("%5.5s", "foobar")).to eq("fooba")

      expect(format("%.5s", "foobar")).to eq("fooba")
      expect(format("%.*s", 5, "foobar")).to eq("fooba")
    end
  end

  it "should format a character with specifier 'c'" do
    expect(format("%c", 97)).to eq("a")
    expect(format("%c", 'a')).to eq("a")
  end

  it "should format a string with specifier 's'" do
    expect(format("%s", "foo")).to eq("foo")
  end

  it "should format an object with specifier 'p'" do
    expect(format("%p", "foo")).to eq("\"foo\"")
  end

  it "should format an integer with specifier 'd' or 'i'" do
    expect(format("%d", -1)).to eq("-1")
    expect(format("%d", 3.1)).to eq("3")
  end

  it "should format an integer with specifier 'u'" do
    expect(format("%u", -1)).to eq("-1")
  end

  it "should format an integer with specifier 'b', 'B', 'o', 'x' or 'X'" do
    expect(format("%b", 10)).to eq("1010")
    expect(format("%B", 10)).to eq("1010")
    expect(format("%o", 10)).to eq("12")
    expect(format("%x", 10)).to eq("a")
    expect(format("%X", 10)).to eq("A")

    expect(format("%x", -1)).to eq("-1")  # incompatible
  end

  it "should format a floating number with specifier 'f', 'e', 'E', 'g' or 'G'" do
    expect(format("%f", 1.0)).to eq("1.000000")
    expect(format("%e", 1.0) =~ /^1\.000000e\+0*0$/).not_to eq(nil)
    expect(format("%g", 1.0)).to eq("1.00000")  # incompatible

    expect(format("%f", 10.1)).to eq("10.100000")
    expect(format("%E", 10.1) =~ /^1\.010000E\+0*1$/).not_to eq(nil)
    expect(format("%g", 10.1)).to eq("10.1000")  # incompatible

    expect(format("%g", 1000000) =~ /^1.00000e\+0*6$/).not_to eq(nil)
    expect(format("%G", 0.0000001) =~ /^1.00000E-0*7$/).not_to eq(nil)
  end

  it "should format special floating number special values" do
    expect(format("%f",  1.0/0)).to eq("Infinity")
    expect(format("%f", -1.0/0)).to eq("-Infinity")
    expect(format("%f",  0.0/0)).to eq("NaN")

    expect(format("%E",  1.0/0)).to eq("INFINITY")
    expect(format("%E", -1.0/0)).to eq("-INFINITY")
    expect(format("%E",  0.0/0)).to eq("NAN")
  end

  it "should take specified index of argument if '$' is specified" do
    expect(format("%d, %x, %o", 1, 2, 3)).to eq("1, 2, 3")
    expect(format("%3$d, %2$x, %1$o", 1, 2, 3)).to eq("3, 2, 1")

    expect(format("%1$d, %1$x, %1$o", 10)).to eq("10, a, 12")

    expect(format("%1$*2$.*3$f", 1, 5, 2)).to eq(" 1.00")
  end

  it "can output % by escaping it" do
    expect(format("%%")).to eq("%")
  end
end
