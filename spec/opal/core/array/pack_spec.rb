require 'spec_helper'

describe 'Array#pack' do
  describe 'C*' do
    it 'packs standard ASCII bytes' do
      [0, 97, 0, 98, 0, 99].pack('C*').should == 'abc'
    end

    it 'packs multibyte characters' do
      [48, 66, 48, 138, 48, 76, 48, 104].pack('C*').should == 'ありがと'
    end

    it "packs astral plane characters (UTF-16 surrogate pairs)" do
      [216, 81, 221, 35].pack('C*').should == '𤔣'
    end
  end

  describe 'U*' do
    it 'packs standard ASCII characters' do
      [97, 98, 99].pack('U*').should == 'abc'
    end

    it 'packs multibyte characters' do
      [12354, 12426, 12364, 12392].pack('U*').should == 'ありがと'
    end

    it 'packs astral plane characters' do
      [148771].pack('U*').should == '𤔣'
    end
  end
end
