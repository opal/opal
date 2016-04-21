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
  let(:path_reader_shared_full_path) { File.expand_path './spec/lib/shared/path_reader_shared.rb' }

  before do
    path_finder.stub(:find) {|path| nil}
    path_finder.stub(:find).with(path).and_return(full_path)
    path_finder.stub(:paths).and_return(Opal.paths)
  end

  include_examples :path_finder
  include_examples :path_reader do
    let(:path_reader) { file_reader }

    it 'works with absolute paths' do
      expect(path_reader.read(File.expand_path(__FILE__))).not_to be_nil
    end

    it 'works with relative paths starting with ./' do
      path_finder.stub(:find).with('./spec/lib/shared/path_reader_shared.rb', base_path: Dir.pwd).and_return(path_reader_shared_full_path)
      expect(path_reader.read('./spec/lib/shared/path_reader_shared.rb')).not_to be_nil
    end

    it 'expands absolute paths' do
      expect(path_reader.expand(__FILE__)).to eq File.expand_path(__FILE__)
    end

    it 'expands relative paths using finder' do
      expect(path_reader.expand('opal_file')).to eq full_path
    end

    it 'expands relative paths starting with ./' do
      path_finder.stub(:find).with('./spec/lib/shared/path_reader_shared.rb', base_path: Dir.pwd).and_return('foobar')
      expect(path_reader.expand('./spec/lib/shared/path_reader_shared.rb')).to eq('foobar')
    end

    it 'expands relative paths starting with ./ without an extension' do
      path_finder.stub(:find).with('./spec/lib/shared/path_reader_shared', base_path: Dir.pwd).and_return('foobar')
      expect(path_reader.expand('./spec/lib/shared/path_reader_shared')).to eq('foobar')
    end

    it 'works with relative paths starting with ..' do
      path_finder.stub(:find).with("../#{File.basename(Dir.pwd)}/spec/lib/shared/path_reader_shared.rb", base_path: Dir.pwd).and_return(path_reader_shared_full_path)
      expect(path_reader.read("../#{File.basename(Dir.pwd)}/spec/lib/shared/path_reader_shared.rb")).not_to be_nil
    end
  end
end
