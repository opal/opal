require 'cli/spec_helper'
require 'cli/shared/path_reader_shared'
require 'cli/shared/path_finder_shared'
require 'opal/path_reader'


describe Opal::PathReader do
  subject(:file_reader) { described_class.new(path_finder) }
  let(:path_finder) { double('path_finder') }
  let(:path) { 'opal_file' }
  let(:full_path) { File.join(__dir__, 'fixtures', 'opal_file.rb') }
  let(:contents) { File.read(full_path) }

  before do
    path_finder.stub(:find) {|path| nil}
    path_finder.stub(:find).with(path).and_return(full_path)
  end

  include_examples :path_finder
  include_examples :path_reader do
    let(:path_reader) { file_reader }
  end
end
