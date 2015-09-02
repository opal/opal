require 'spec_helper'

describe Opal do
  context '.instance_variable_name!' do
    it 'does not use regular expressions on Opal level, so $` stays the same' do
      'some string' =~ /string/
      post_match = $`

      Opal.instance_variable_name!(:@ivar_name)

      expect($`).to eq(post_match)
    end
  end
end
