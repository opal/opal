require 'spec_helper'

describe 'String#unpack' do
  describe 'C*' do
    it 'unpacks standard ASCII bytes' do
      'abc'.unpack('C*').should == [0, 97, 0, 98, 0, 99]
    end

    it 'unpacks multibyte characters' do
      'ありがと'.unpack('C*').should == [48, 66, 48, 138, 48, 76, 48, 104]
    end

    it "unpacks astral plane characters (UTF-16 surrogate pairs)" do
      char = %x{String.fromCharCode(55377, 56611)}
      char.unpack('C*').should == [216, 81, 221, 35]
    end
  end

  describe 'U*' do
    it 'unpacks standard ASCII characters' do
      'abc'.unpack('U*').should == [97, 98, 99]
    end

    it 'unpacks multibyte characters' do
      'ありがと'.unpack('U*').should == [12354, 12426, 12364, 12392]
    end

    it 'unpacks astral plane characters' do
      char = %x{String.fromCharCode(55377, 56611)}
      char.unpack('U*').should == [148771]
    end
  end
end
