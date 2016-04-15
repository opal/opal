require 'spec_helper'
require 'opal-source-maps'

describe Opal::SourceMap do
  before do
    pathname = 'foo.rb'
    compiler = Opal::Compiler.new("def foo\n123\nend", :file => pathname)
    @source  = compiler.compile
    @map     = Opal::SourceMap.new(compiler.fragments, pathname)
  end

  def parsed_map
    SourceMap::Map.from_json(@map.as_json.to_json)
  end

  def mappings
    mappings = []
    # mappings is not exposed on the ext library
    parsed_map.each do |mapping|
      mappings << mapping
    end
    mappings
  end

  it 'does not blow while generating the map' do
    lambda { @map.as_json }.should_not raise_error
  end

  it 'parses the map without error' do
    parsed_map.should_not be_nil
  end

  it 'identifies line numbers' do
    match = mappings.find {|map| map.original.line == 2 }
    # as of Opal 0.10
    match.generated.line.should == 8
  end

  it 'uses method names' do
    match = mappings.find {|map| map.original.line == 2 }
    match.name.should == 'foo'
  end
end
