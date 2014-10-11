require 'lib/spec_helper'
require 'lib/shared/path_reader_shared'
require 'lib/shared/path_finder_shared'
require 'opal/path_reader'


describe Opal::PathReader do
  subject(:file_reader) { described_class.new(path_finder) }
  let(:path_finder) { double('path_finder') }
  let(:path) { 'opal_file' }
  let(:full_path) { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
  let(:contents) { File.read(full_path) }

  before do
    path_finder.stub(:find) {|path| nil}
    path_finder.stub(:find).with(path).and_return(full_path)
    path_finder.stub(:paths).and_return(Opal.paths)
  end

  include_examples :path_finder
  include_examples :path_reader do
    let(:path_reader) { file_reader }
  end
end
