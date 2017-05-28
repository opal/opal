require 'spec_helper'

module MarshalExtension
end

class MarshalUserRegexp < Regexp
end

class UserMarshal
  attr_reader :data

  def initialize
    @data = 'stuff'
  end
  def marshal_dump() 'data' end
  def marshal_load(data) @data = data end
  def ==(other) self.class === other and @data == other.data end
end

describe 'Marshal.dump' do
  it 'dumps non-empty Array' do
    expect(Marshal.dump(['a', 1, 2])).to eq("\u0004\b[\b\"\u0006ai\u0006i\a")
  end

  it 'dumps case-sensitive regexp' do
    expect(Marshal.dump(/\w+/)).to eq("\u0004\b/\b\\w+\u0000")
  end

  it 'dumps case-insensitive regexp' do
    expect(Marshal.dump(/\w+/i)).to eq("\u0004\b/\b\\w+\u0001")
  end

  it "dumps a Float" do
    Marshal.dump(123.4567).should == "\004\bf\r123.4567"
    Marshal.dump(-0.841).should == "\x04\bf\v-0.841"
    Marshal.dump(9876.345).should == "\004\bf\r9876.345"
    Marshal.dump(Float::INFINITY).should == "\004\bf\binf"
    Marshal.dump(-Float::INFINITY).should == "\004\bf\t-inf"
    Marshal.dump(Float::NAN).should == "\004\bf\bnan"
  end

  it "dumps a Regexp with flags" do
    Marshal.dump(/\w/im).should == "\x04\b/\a\\w\u0005"
  end

  it 'dumps an extended Regexp' do
    Marshal.dump(/\w/.extend(MarshalExtension)).should == "\x04\be:\u0015MarshalExtension/\a\\w\u0000"
  end

  it 'dumps object#marshal_dump when object responds to #marshal_dump' do
    Marshal.dump(UserMarshal.new).should == "\u0004\bU:\u0010UserMarshal\"\tdata"
  end

  it 'saves a link to an object before processing its instance variables' do
    top = Object.new
    ref = Object.new
    a = Object.new
    b = Object.new
    c = Object.new

    top.instance_variable_set(:@a, a)
    top.instance_variable_set(:@b, b)
    top.instance_variable_set(:@a, c)
    top.instance_variable_set(:@ref, ref)

    expected = "\u0004\b[\ao:\vObject\b:\a@ao:\vObject\u0000:\a@bo:\vObject\u0000:\t@refo:\vObject\u0000@\t"
    Marshal.dump([top, ref]).should == expected
    loaded = Marshal.load(expected)
    loaded[0].instance_variable_get(:@ref).object_id.should == loaded[1].object_id
  end
end
