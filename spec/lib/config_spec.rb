require 'lib/spec_helper'
require 'opal/config'

describe Opal::Config do
  describe '.default_config' do
    it 'is new each time' do
      default_config1 = described_class.default_config
      default_config2 = described_class.default_config
      expect(default_config1).to eq(default_config2)
      expect(default_config1).not_to equal(default_config2)
    end
  end
end
