require 'cli/spec_helper'

shared_examples :path_finder do
  it 'responds to #path' do
    expect(path_finder.read(path)).to eq(contents)
  end
end
