require 'lib/spec_helper'

shared_examples :path_reader do
  # @param path
  # the path we want to read
  #
  # @param contents
  # the contents we expect to be read
  #
  it 'responds to #path' do
    expect(path_reader.read(path)).to eq(contents)
  end

  it 'returns nil if the file is missing' do
    expect(path_reader.read('unexpected-path!')).to be_nil
  end
end
