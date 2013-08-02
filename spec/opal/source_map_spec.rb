require 'spec_helper'
require 'opal-source-maps'

describe Opal::SourceMap do
  before do
    pathname = 'foo.rb'
    @source = Opal.parse('1 + 1', pathname)
    @map    = Opal::SourceMap.new(@source, pathname)
  end

  pending 'source has the magic comments' do
    Opal::SourceMap::FILE_REGEXP.should =~ @source
    Opal::SourceMap::LINE_REGEXP.should =~ @source
  end

  it 'does not blow while generating the map' do
    lambda { @map.as_json }.should_not raise_error
  end
end
