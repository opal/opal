# backtick_javascript: true

require 'spec_helper'

describe 'Encoding' do
  it 'supports US-ASCII' do
    skip if OPAL_PLATFORM == 'deno' # see filters/platform/deno
    "è".encoding.name.should == 'UTF-8'
    "è".force_encoding('ASCII').should == "\xC3\xA8"
    "è".force_encoding('ascii').should == "\xC3\xA8"
    "è".force_encoding('US-ASCII').should == "\xC3\xA8"
    "è".force_encoding('us-ascii').should == "\xC3\xA8"
    "è".force_encoding('ASCII-8BIT').should == "\xC3\xA8"
    "è".force_encoding('ascii-8bit').should == "\xC3\xA8"
    "è".force_encoding('BINARY').should == "\xC3\xA8"
    "è".force_encoding('binary').should == "\xC3\xA8"
  end

  describe '.find' do
    it 'finds the encoding regardless of the case' do
      Encoding.find('ASCII').should == Encoding::ASCII
      Encoding.find('ascii').should == Encoding::ASCII
      Encoding.find('US-ASCII').should == Encoding::ASCII
      Encoding.find('us-ascii').should == Encoding::ASCII
      Encoding.find('ASCII-8BIT').should == Encoding::BINARY
      Encoding.find('ascii-8bit').should == Encoding::BINARY
      Encoding.find('BINARY').should == Encoding::BINARY
      Encoding.find('binary').should == Encoding::BINARY
    end
  end
end

describe 'strip methods' do
  def strip_cases(before, after, method)
    before = before ? 1 : 0
    after = after ? 1 : 0

    it 'strip spaces' do
      "#{"  " * before}ABC#{"  " * after}".send(method).should == "ABC"
    end

    it 'strips NUL bytes' do
      "#{"\0" * before}ABC#{"\0" * after}".send(method).should == "ABC"
    end

    it "doesn't strip NBSPs" do
      "#{"\u{a0}" * before}ABC#{"\u{a0}" * after}".send(method).should != "ABC"
    end

    it "strips all other supported whitespace characters" do
      "#{"\r\n\t\v\f" * before}ABC#{"\r\n\t\v\f" * after}".send(method).should == "ABC"
    end
  end

  describe '#lstrip' do
   strip_cases true, false, :lstrip
  end

  describe '#rstrip' do
    strip_cases false, true, :rstrip
  end

  describe '#strip' do
    strip_cases true, true, :strip
  end
end

describe 'Unicode Astral Plane' do
  # '𝌆' is a 2 part surrogate
  # in Ruby: '𝌆'.length == 1
  # in JavaScript: '𝌆'.length == 2
  # '𝌆'.charCodeAt(0) == 55348, first half of surrogate, high
  # '𝌆'.charCodeAt(1) == 57094, second half of surrogate, low

  it 'reports the correct String #length' do
    'a𝌆'.size.should == 2
  end

  it 'returns the correct character or string by #[]' do
    'a𝌆'[1].should == '𝌆'
    'a𝌆a𝌆a𝌆'[1..3].should == '𝌆a𝌆'
    'a𝌆a𝌆a𝌆'[-5..-3].should == '𝌆a𝌆'
    'a𝌆a𝌆a𝌆'['𝌆'].should == '𝌆'
    'a𝌆a𝌆a𝌆'['𝌆a'].should == '𝌆a'
    'a𝌆a𝌆a𝌆'[/a/].should == 'a'
    'a𝌆a𝌆a𝌆'[/𝌆/].should == '𝌆'
    'a𝌆a𝌆a𝌆'[/#{`String.fromCharCode(55348)`}/].should == nil
    'a𝌆a𝌆a𝌆'[/#{`String.fromCharCode(57094)`}/].should == nil
    'a𝌆a𝌆a𝌆'[Regexp.new(`String.fromCharCode(55348)`)].should == nil
    'a𝌆a𝌆a𝌆'[Regexp.new(`String.fromCharCode(57094)`)].should == nil
  end

  it 'correctly compares by #<=>' do
    str1 = "ça va bien"
    str2 = "c\u0327a va bien"
    (str1 <=> str2).should == 1
    (str1.unicode_normalize <=> str2.unicode_normalize).should == 0
  end

  it 'correctly compares by #==' do
    str1 = "ça va bien"
    str2 = "c\u0327a va bien"
    (str1 == str2).should == false
    (str1.unicode_normalize == str2.unicode_normalize).should == true
  end

  it 'does #center correctly' do
    'a𝌆a'.center(4).should == 'a𝌆a '
  end

  it 'does #ljust correctly' do
    'a𝌆a'.ljust(4).should == 'a𝌆a '
  end

  it 'does #rjust correctly' do
    'a𝌆a'.rjust(4).should == ' a𝌆a'
  end

  it 'returns #chr correctly' do
    '𝌆a'.chr.should == '𝌆'
  end

  it '#delete_prefix correctly' do
    '𝌆a'.delete_prefix(`String.fromCharCode(55348)`).should == '𝌆a'
    '𝌆a'.delete_prefix('𝌆').should == 'a'
  end

  it '#delete_suffix correctly' do
    'a𝌆'.delete_suffix(`String.fromCharCode(57094)`).should == 'a𝌆'
    'a𝌆'.delete_suffix('𝌆').should == 'a'
  end

  it 'correctly reports #end_with?' do
    'a𝌆'.end_with?(`String.fromCharCode(57094)`).should == false
    'a𝌆'.end_with?('𝌆').should == true
  end

  it 'correctly reports #include?' do
    'a𝌆'.include?(`String.fromCharCode(55348)`).should == false
    'a𝌆'.include?('𝌆').should == true
    'a𝌆a𝌆'.include?('𝌆a').should == true
  end

  it 'returns correct #index' do
    'a𝌆a'.index(`String.fromCharCode(55348)`).should == nil
    'a𝌆a'.index('𝌆').should == 1
    'a𝌆a𝌆a'.index('𝌆a').should == 1
  end

  it 'returns correct #partition' do
    '𝌆a𝌆a𝌆a'.partition(`String.fromCharCode(55348)`).should == ['𝌆a𝌆a𝌆a', '', '']
    '𝌆a𝌆a𝌆a'.partition('𝌆').should == ['', '𝌆', 'a𝌆a𝌆a']
  end

  it '#reverse correctly' do
    '𝌆a𝌆a𝌆a'.reverse.should == 'a𝌆a𝌆a𝌆'
  end

  it 'returns correct #rindex' do
    'a𝌆a'.rindex(`String.fromCharCode(55348)`).should == nil
    'a𝌆a'.rindex('𝌆').should == 1
    'a𝌆a𝌆a'.rindex('𝌆a').should == 3
  end

  it 'returns correct #rpartition' do
    '𝌆a𝌆a𝌆a'.rpartition(`String.fromCharCode(55348)`).should == ['', '', '𝌆a𝌆a𝌆a']
    '𝌆a𝌆a𝌆a'.rpartition('𝌆').should == ['𝌆a𝌆a', '𝌆', 'a']
  end

  it 'correctly reports #start_with?' do
    '𝌆a'.start_with?(`String.fromCharCode(55348)`).should == false
    '𝌆a'.start_with?('𝌆').should == true
  end

  it 'transliterates correctly with #tr' do
    '𝌆a𝌆a𝌆a'.tr(`String.fromCharCode(55348)`, 'c').should == '𝌆a𝌆a𝌆a'
    '𝌆a𝌆a𝌆a'.tr('𝌆', 'c').should == 'cacaca'
    '𝌆a𝌆a𝌆a'.tr('a', 'c').should == '𝌆c𝌆c𝌆c'
    '𝌆a𝌆a𝌆a'.tr('𝌆a', 'bc').should == 'bcbcbc'
    '𝌆a𝌆b𝌆a'.tr('𝌆b', 'bc').should == 'babcba'
  end

  it 'transliterates correctly with #tr_s' do
    '𝌆a𝌆a𝌆a'.tr_s(`String.fromCharCode(55348)`, 'c').should == '𝌆a𝌆a𝌆a'
    '𝌆a𝌆a𝌆a'.tr_s('𝌆', 'c').should == 'cacaca'
    '𝌆a𝌆a𝌆a'.tr_s('a', 'c').should == '𝌆c𝌆c𝌆c'
    '𝌆a𝌆a𝌆a'.tr_s('𝌆a', 'bc').should == 'bcbcbc'
    '𝌆a𝌆b𝌆a'.tr_s('𝌆b', 'bc').should == 'babcba'
    '𝌆𝌆𝌆aaa'.tr_s('𝌆a', 'bc').should == 'bc'
  end

  it 'splits correctly' do
    '𝌆a𝌆a𝌆a'.split('').should == ["𝌆", "a", "𝌆", "a", "𝌆", "a"]
    '𝌆a𝌆a𝌆a'.split(`String.fromCharCode(55348)`).should == ['𝌆a𝌆a𝌆a']
    '𝌆a𝌆a𝌆a'.split(`String.fromCharCode(57094)`).should == ['𝌆a𝌆a𝌆a']
    '𝌆a𝌆a𝌆a'.split('a').should == ["𝌆", "𝌆", "𝌆"]
    '𝌆a𝌆a𝌆a'.split('𝌆').should == ["", "a", "a", "a"]
  end

  it 'chomps correctly' do
    '𝌆a𝌆a𝌆'.chomp(`String.fromCharCode(57094)`).should == '𝌆a𝌆a𝌆'
    '𝌆a𝌆a𝌆'.chomp(`String.fromCharCode(55348) + "a𝌆"`).should == '𝌆a𝌆a𝌆'
    '𝌆a𝌆a𝌆'.chomp("𝌆").should == '𝌆a𝌆a'
    '𝌆a𝌆a𝌆'.chomp("a𝌆").should == '𝌆a𝌆'
  end

  it 'chops correctly' do
    '𝌆a𝌆a𝌆'.chop.should == '𝌆a𝌆a'
  end

  it 'skips the surrogate range in #next and #succ' do
    s = `String.fromCharCode(0xD7FF)`
    s.next.ord.should == 0xE000
    s.succ.ord.should == 0xE000
  end

  it 'skips the surrogate range in #upto' do
    res = []
    s = `String.fromCharCode(0xD7FF)`
    s.upto(`String.fromCharCode(0xE000)`) do |v|
      res << v.ord
    end
    res.should == [0xD7FF, 0xE000]
  end

  it 'counts correctly' do
    '𝌆a𝌆a𝌆a'.count(`String.fromCharCode(55348)`).should == 0
    '𝌆a𝌆a𝌆a'.count(`String.fromCharCode(57094)`).should == 0
    '𝌆a𝌆a𝌆a'.count(`String.fromCharCode(57094) + 'a'`).should == 3
    '𝌆a𝌆a𝌆a'.count(`String.fromCharCode(55348) + 'a'`).should == 3
    '𝌆a𝌆a𝌆a'.count(`String.fromCharCode(55348) + '𝌆'`).should == 3
    '𝌆a𝌆a𝌆a'.count('𝌆').should == 3
    '𝌆a𝌆a𝌆a'.count('a𝌆').should == 6
  end

  it 'deletes correctly' do
    '𝌆a𝌆a𝌆a'.delete(`String.fromCharCode(55348)`).should == '𝌆a𝌆a𝌆a'
    '𝌆a𝌆a𝌆a'.delete(`String.fromCharCode(57094)`).should == '𝌆a𝌆a𝌆a'
    '𝌆a𝌆a𝌆a'.delete(`String.fromCharCode(57094) + 'a'`).should == '𝌆𝌆𝌆'
    '𝌆a𝌆a𝌆a'.delete(`String.fromCharCode(55348) + 'a'`).should == '𝌆𝌆𝌆'
    '𝌆a𝌆a𝌆a'.delete(`String.fromCharCode(55348) + '𝌆'`).should == 'aaa'
    '𝌆a𝌆a𝌆a'.delete('𝌆').should == 'aaa'
    '𝌆a𝌆a𝌆a'.delete('a𝌆').should == ''
  end

  it 'iterates through lines correctly' do
    '𝌆a𝌆a𝌆a'.each_line(`String.fromCharCode(55348)`).count.should == 1
    '𝌆a𝌆a𝌆a'.each_line(`String.fromCharCode(57094)`).count.should == 1
    '𝌆a𝌆a𝌆a'.each_line('𝌆').count.should == 4
  end
end
