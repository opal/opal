describe "String#tr_s" do
  it "replaces occurrences of character with substitute, dropping repeating substitutes" do
    # identity checks (no substitution)
    'abc'.tr_s('', 'a').should == 'abc'
    'aabbcc'.tr_s('', 'a').should == 'aabbcc'

    # single char substitutions
    'a'.tr_s('a', 'b').should == 'b'
    'aa'.tr_s('a', 'b').should == 'b'
    'bbabcbb'.tr_s('b', 'z').should == 'zazcz'
    'hello'.tr_s('l', 'r').should == 'hero'

    # multiple char substitutions
    'aabbcc'.tr_s('abc', 'abc').should == 'abc'
    'hello'.tr_s('el', '*').should == 'h*o'
    'hello'.tr_s('el', 'hx').should == 'hhxo'

    # inverted substitutions
    'hello'.tr_s('^aeiou', '*').should == '*e*o'

    # range substitutions
    'abc'.tr_s('a-c', '*').should == '*'
    'hello'.tr_s('e-lo', 'rb').should == 'brb'
    'hello'.tr_s('a-y', 'b-z').should == 'ifmp'

    # truncation
    'abcd'.tr_s('a', '').should == 'bcd'
    'abcd'.tr_s('abc', '').should == 'd'
    'abcd'.tr_s('b-d', '').should == 'a'
  end
end
