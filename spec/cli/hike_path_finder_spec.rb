require 'cli/spec_helper'
require 'cli/shared/path_finder_shared'
require 'opal/hike_path_finder'

describe Opal::HikePathFinder do
  subject(:path_finder) { described_class.new(root) }
  let(:root) { File.expand_path('..', __FILE__) }
  let(:path) { 'fixtures/opal_file' }
  let(:full_path) { File.join(root, path + ext) }
  let(:ext) { '.rb' }

  include_examples :path_finder

  context 'with absolute paths' do
    it 'returns the path if exists' do
      expect(path_finder.find(full_path)).to eq(full_path)
    end

    it 'gives nil if it is missing' do
      expect(path_finder.find(full_path+'/not-real')).to eq(nil)
    end
  end
end
