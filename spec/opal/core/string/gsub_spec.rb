require 'spec_helper'

describe 'String#gsub' do
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
end
