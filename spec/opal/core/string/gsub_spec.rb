require 'spec_helper'

describe 'String#gsub' do
  it 'handles recursive gsub' do
    PassSlotRx = /{(\d+)}/
    def recurse_gsub text
      text.gsub(PassSlotRx) {
        index = $1.to_i
        if index == 0
          recurse_gsub '{1}'
        else
          'value'
        end
      }
    end
    result = recurse_gsub '<code>{0}</code>'
    result.should == '<code>value</code>'
  end
end
