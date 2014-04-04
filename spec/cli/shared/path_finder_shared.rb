require 'cli/spec_helper'

shared_examples :path_finder do
  # @param path
  # the path we want to read
  #
  # @param full_path
  # the expanded path that should be found
  #
  it 'responds to #path' do
    expect(path_finder.find(path)).to eq(full_path)
  end
end


