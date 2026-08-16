require 'lib/spec_helper'
require 'opal/path_reader'
require 'tmpdir'

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

  it 'works with relative paths starting with ../' do
    expect(path_reader.read("../#{File.basename(Dir.pwd)}/spec/lib/spec_helper.rb")).not_to be_nil
  end

  # See https://github.com/opal/opal/issues/778
  describe 'paths starting with ./' do
    context 'without a cwd' do
      it 'resolves them through the load path' do
        expect(path_reader.expand("./#{path}")).to eq(full_path)
      end

      # Without a cwd there is no directory to be relative to, so resolution
      # must not silently start depending on wherever the process happens to be.
      it 'does not resolve them against the current working directory' do
        expanded = Dir.chdir(Dir.tmpdir) { path_reader.expand("./#{path}") }

        expect(expanded).to eq(full_path)
      end
    end

    context 'with a cwd' do
      subject(:path_reader) { described_class.new(Opal.paths, described_class::DEFAULT_EXTENSIONS, cwd: cwd) }

      around { |example| Dir.mktmpdir { |dir| @cwd = dir; example.run } }

      let(:cwd) { @cwd }

      # MRI resolves './foo' against the CWD, and a cwd opts into that.
      it 'resolves them against the cwd, even when absent from the load path' do
        File.write(File.join(cwd, 'in_cwd.rb'), '')

        expect(path_reader.expand('./in_cwd.rb')).to eq(File.join(cwd, 'in_cwd.rb'))
      end

      it 'resolves them against the cwd without an explicit extension' do
        File.write(File.join(cwd, 'in_cwd.rb'), '')

        expect(path_reader.expand('./in_cwd')).to eq(File.join(cwd, 'in_cwd.rb'))
      end

      # The cwd takes precedence, but the load path still backs it up, so
      # setting a cwd never makes a previously resolvable require stop working.
      it 'falls back to the load path when the cwd has no such file' do
        expect(path_reader.expand("./#{path}")).to eq(full_path)
      end

      # Resolution follows the configured cwd, not the process one.
      it 'ignores the process working directory' do
        File.write(File.join(cwd, 'in_cwd.rb'), '')

        expanded = Dir.chdir(Dir.tmpdir) { path_reader.expand('./in_cwd.rb') }

        expect(expanded).to eq(File.join(cwd, 'in_cwd.rb'))
      end
    end
  end
end
