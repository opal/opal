require 'lib/spec_helper'

# Below the helpers expected from a spec that
# includes these shared examples:
#
# @object [PathReader] path_reader the object under test
# @method [String]     path        the path we want to read
# @method [String]     contents    the contents we expect to be read
#
shared_examples :path_reader do
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
    it 'responds to #path' do
      expect(path_reader.read(path)).to eq(contents)
    end

    it 'returns nil if the file is missing' do
      expect(path_reader.read('unexpected-path!')).to be_nil
    end
  end
end
