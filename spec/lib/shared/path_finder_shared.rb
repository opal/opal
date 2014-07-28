require 'lib/spec_helper'

shared_examples :path_finder do
  # @param path
  # the path we want to read
  #
  # @param full_path
  # the expanded path that should be found
  #
  it 'returns the full path if the path exists' do
    expect(path_finder.find(path)).to eq(full_path)
  end

  it 'returns nil if the path is missing' do
    expect(path_finder.find('unexpected-path')).to eq(nil)
  end
end


