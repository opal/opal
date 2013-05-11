describe "String#tr" do
  it "replaces occurances of character with substitute" do
    # identity checks (no substitution)
    'abc'.tr('', 'z').should == 'abc'
    'abc'.tr('a', 'a').should == 'abc'
    'abc'.tr('a', 'az').should == 'abc'

    # single char substitutions
    'a'.tr('a', 'b').should == 'b'
    'aa'.tr('a', 'b').should == 'bb'
    'abc'.tr('b', 'z').should == 'azc'
    'hello'.tr('e', 'ip').should == 'hillo'

    # multiple char substitutions
    'hello'.tr('el', 'ip').should == 'hippo'
    'hello'.tr('aeiou', '*').should == 'h*ll*'

    # inverted substitutions
    'hello'.tr('^aeiou', '*').should == '*e**o'

    # range substitutions
    'abc'.tr('a-c', '*').should == '***'
    'hello'.tr('e-lo', 'ab').should == 'babbb'
    'hello'.tr('a-y', 'b-z').should == 'ifmmp'

    # truncation
    'abcd'.tr('a', '').should == 'bcd'
    'abcd'.tr('abc', '').should == 'd'
    'abcd'.tr('b-d', '').should == 'a'
  end
end
