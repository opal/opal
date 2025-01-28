require 'spec_helper'
require 'json'
require 'matrix'

describe Bignum do
  it 'supports basic operations' do
    (2.to_bn + 2).should == 4
    (2 + 2.to_bn).should == 4
    (4.to_bn ** 4 ** 4).should == "13407807929942597099574024998205846127479365820592393377723561443721764030073546976801874298166903427690031858186486050853753882811946569946433649006084096".to_bn
    (24 > 23.to_bn).should == true
    (23 > 24.to_bn).should == false
    (2.to_bn << 100).should == "2535301200456458802993406410752".to_bn
    (-2.to_bn.abs).should == 2
    2.to_bn.should == 2
    2.should == 2.to_bn
  end

  it 'supports Math operations via coertion to Float' do
    Math.sin(2.to_bn).should == 0.9092974268256817
    Math.sqrt(2.to_bn).should == 1.4142135623730951
    Math.asin(1.to_bn).should == 1.5707963267948966
    Math.sqrt(1000000000000000000.to_bn ** 2).should == 1000000000000000000
    Math.cbrt(1000000000000000000.to_bn ** 3).should == 1000000000000000000
  end

  it 'works with float' do
    (2.to_bn + 2.2).should == 4.2
    (2.2 + 2.to_bn).should == 4.2
    (2.to_bn + 2).class.should == Bignum
    (2.to_bn + 2.2).class.should == Number
  end

  it 'supports other methods' do
    2.to_bn.times.to_a.should == [0,1]
    "1293849781234798123479812937847981239784978123984".to_bn.to_json.should == "1293849781234798123479812937847981239784978123984"
  end

  it 'works with Rationals' do
    (Rational(1, '123823475789234752789345923789457892378945987234527893457892389745789239874598791289'.to_bn).to_s).should == '1/123823475789234752789345923789457892378945987234527893457892389745789239874598791289'
    (Rational(1, '12382347578923475'.to_bn) + Rational(1, '1231231241234123412343'.to_bn)).to_s.should == '1231243623581702335818/15245533178990293036277123473467451925'
    '23427834781278312893418923489121298348989344'.to_bn.to_r.to_s.should == '23427834781278312893418923489121298348989344/1'
    (Rational(0.5) + '989234891289348912893489123489192834891298342'.to_bn).to_s.should == '1978469782578697825786978246978385669782596685/2'
  end

  it 'works with Complex' do
    (('989234891289348912893489123489192834891298342'.to_bn + 1i) * 6i).to_s.should == '-6+5935409347736093477360934740935157009347790052i'
    (('989234891289348912893489123489192834891298342'.to_bn + 1i) ** 6i).to_s.should == '0.9201585374726815-0.39154599463681883i'
  end

  it 'works with Matrix' do
    det = Matrix[[1.to_bn,0.to_bn], [0.to_bn,1.to_bn]].det
    det.class.should == Bignum
    det.should == 1
  end

  it 'has correct typing expectations' do
    (Integer === 1.to_bn).should == true
    (Bignum === 1.to_bn).should == true
    (Float === 1.to_bn).should == false
  end
end
