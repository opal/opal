require 'spec_helper'
require 'source_map'

describe 'SourceMap::VLQ' do
  it 'encodes properly' do
    SourceMap::VLQ.encode([0]).should == 'A'
  end
end
