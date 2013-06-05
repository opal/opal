require 'spec_helper'
require 'opal/source_map'

describe Opal::SourceMap do
  let(:assets) { Opal::Environment.new }
  let(:asset)  { assets['opal'] }
  let(:source) { asset.to_s }
  let(:map)    { described_class.new(source, asset.pathname.to_s) }

  it 'source has the magic comments' do
    described_class::FILE_REGEXP.should match(source)
    described_class::LINE_REGEXP.should match(source)
  end

  it 'does not blow while generating the map' do
    expect { map.as_json }.not_to raise_exception
  end
end
