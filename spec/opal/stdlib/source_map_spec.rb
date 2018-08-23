require 'spec_helper'
require 'opal/source_map'

describe 'Opal::SourceMap::VLQ' do
  it 'encodes properly' do
    Opal::SourceMap::VLQ.encode([0]).should == 'A'
  end
end
