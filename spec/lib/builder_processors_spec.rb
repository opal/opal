require 'lib/spec_helper'
require 'opal/builder_processors'

describe Opal::Builder::RubyProcessor do
  it 'compiles ruby to js' do
    processor = described_class.new('puts 5', '-e')
    expect(processor.to_s).to include('$puts(5)')
  end

  describe ':requirable option' do
    it 'is respected' do
      processor = described_class.new('puts 5', '-e', requirable: true)
      expect(processor.to_s).to include('Opal.modules[')
    end

    it 'defaults to "false"' do
      processor = described_class.new('puts 5', '-e')
      expect(processor.to_s).not_to include('Opal.modules[')
    end
  end

  it 'fills required_trees' do
    processor = described_class.new('require_tree "./pippo"', '-e')
    expect(processor.required_trees).to eq(['pippo'])
  end
end

