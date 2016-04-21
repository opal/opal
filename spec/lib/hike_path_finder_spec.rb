require 'lib/spec_helper'
require 'lib/shared/path_finder_shared'
require 'opal/hike_path_finder'

describe Opal::HikePathFinder do
  subject(:path_finder) { described_class.new(root) }
  let(:root) { File.expand_path('..', __FILE__) }
  let(:path) { 'fixtures/opal_file' }
  let(:full_path) { File.join(root, path + ext) }
  let(:ext) { '.rb' }
  let(:path_reader_shared_full) { File.expand_path './spec/lib/shared/path_reader_shared.rb' }

  include_examples :path_finder

  context 'with absolute paths' do
    it 'returns the path if exists' do
      expect(path_finder.find(full_path)).to eq(full_path)
    end

    it 'gives nil if it is missing' do
      expect(path_finder.find(full_path+'/not-real')).to eq(nil)
    end
  end

  context 'with relative paths' do
    it 'starting with ./ and an extension' do
      expect(path_finder.find_relative_current_dir('./spec/lib/shared/path_reader_shared.rb')).to eq(path_reader_shared_full)
    end

    it 'starting with ./ and no extension' do
      expect(path_finder.find_relative_current_dir('./spec/lib/shared/path_reader_shared')).to eq(path_reader_shared_full)
    end
  end

  context 'relative in a different directory' do
    around do |ex|
      # expand this before we change directories
      @expected_path = path_reader_shared_full
      Dir.chdir './spec/lib/shared' do
        ex.run
      end
    end

    it 'starting with ./ and an extension' do
      expect(path_finder.find_relative_current_dir('./path_reader_shared.rb')).to eq(@expected_path)
    end

    it 'starting with ./ and no extension' do
      expect(path_finder.find_relative_current_dir('./path_reader_shared')).to eq(@expected_path)
    end
  end
end
