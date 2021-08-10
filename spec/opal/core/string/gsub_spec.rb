require 'spec_helper'

describe 'String' do
  describe '#gsub' do
    it 'handles recursive gsub' do
      pass_slot_rx = /{(\d+)}/
      recurse_gsub = -> text {
        text.gsub(pass_slot_rx) {
          index = $1.to_i
          if index == 0
            recurse_gsub.call '{1}'
          else
            'value'
          end
        }
      }
      result = recurse_gsub.call '<code>{0}</code>'
      result.should == '<code>value</code>'
    end

    it 'works well with zero-length matches' do
      expect("test".gsub(/^/, '2')).to eq "2test"
      expect("test".gsub(/$/, '2')).to eq "test2"
      expect("test".gsub(/\b/, '2')).to eq "2test2"
    end
  end

  describe '#sub' do
    it 'works well with zero-length matches' do
      expect("test".sub(/^/, '2')).to eq "2test"
      expect("test".sub(/$/, '2')).to eq "test2"
      expect("test".sub(/\b/, '2')).to eq "2test"
    end
  end
end
