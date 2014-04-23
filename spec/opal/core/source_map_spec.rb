require 'spec_helper'
require 'opal-source-maps'

describe Opal::SourceMap do
  before do
    pathname = 'foo.rb'
    compiler = Opal::Compiler.new("1 + 1", :file => pathname)
    @source  = compiler.compile
    @map     = Opal::SourceMap.new(compiler.fragments, pathname)
  end

  it 'does not blow while generating the map' do
    lambda { @map.as_json }.should_not raise_error
  end
end
