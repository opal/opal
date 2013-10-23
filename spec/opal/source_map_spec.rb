require 'spec_helper'
require 'opal-source-maps'

describe Opal::SourceMap do
  before do
    pathname = 'foo.rb'
    parser   = Opal::Compiler.new
    @source  = parser.parse("1 + 1", pathname)
    @map     = Opal::SourceMap.new(parser.fragments, pathname)
  end

  it 'does not blow while generating the map' do
    lambda { @map.as_json }.should_not raise_error
  end
end
