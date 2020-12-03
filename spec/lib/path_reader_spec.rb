require 'lib/spec_helper'
require 'opal/path_reader'

RSpec.describe Opal::PathReader do
  subject(:path_reader) { described_class.new }
  let(:path) { 'opal_file' }
  let(:full_path) { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
  let(:contents) { File.read(full_path, mode: "rb:UTF-8") }

  before do
    allow_any_instance_of(Opal::Hike::Trail).to receive(:find) {|path| nil}
    allow_any_instance_of(Opal::Hike::Trail).to receive(:find).with(path).and_return(full_path)
  end

  describe '#paths' do
    it 'is an Enumberable' do
      expect(path_reader.paths).to be_an(Enumerable)
    end

    it 'includes Opal.paths' do
      paths = path_reader.paths.to_a
      Opal.paths.each { |path| expect(paths).to include(path) }
    end
  end

  describe '#read' do
    it 'reads the contents from the path' do
      expect(path_reader.read(path)).to eq(contents)
    end

    it 'returns nil if the file is missing' do
      expect(path_reader.read('unexpected-path!')).to be_nil
    end
  end

  it 'works with absolute paths' do
    expect(path_reader.read(File.expand_path(__FILE__))).not_to be_nil
  end

  it 'works with relative paths starting with ./' do
    expect(path_reader.read('./spec/lib/spec_helper.rb')).not_to be_nil
  end

  it 'works with absolute paths' do
    expect(path_reader.read("../#{File.basename(Dir.pwd)}/spec/lib/spec_helper.rb")).not_to be_nil
  end
end
