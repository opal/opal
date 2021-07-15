require 'lib/spec_helper'
require 'opal/builder_processors'

RSpec.describe Opal::BuilderProcessors::JsProcessor do
  it 'maps to one fragment per line' do
    processor = described_class.new("line1\n line2\n  line3", 'file.js')
    expect(processor.source_map.fragments.map(&:code)).to eq([
      "line1\n",
      " line2\n",
      "  line3\n",
      "Opal.loaded([\"file.js\"]);",
    ])
  end

  it 'adds loading code at the end of the source' do
    processor = described_class.new("line1\n line2\n  line3", 'file.js')
    expect(processor.source).to eq(%Q{line1\n line2\n  line3\nOpal.loaded(["file.js"]);})
  end
end

RSpec.describe Opal::BuilderProcessors::RubyProcessor do
  it 'compiles ruby to js' do
    processor = described_class.new('puts 5', '-e')
    expect(processor.to_s).to include('[Opal.s.$puts](5)')
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
    expect(processor.required_trees).to eq(['./pippo'])
  end
end

