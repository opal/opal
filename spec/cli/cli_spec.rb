require 'cli/spec_helper'
require 'opal/cli'
require 'stringio'

describe Opal::CLI do
  let(:fake_stdout) { StringIO.new }
  let(:file)    { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
  let(:options) { nil }
  subject(:cli) { described_class.new(options) }

  context 'with a file' do
    let(:options) { {:filename => file} }

    it 'runs the file' do
      expect_output_of{ subject.run }.to eq("hi from opal!\n")
    end
  end

  describe ':evals option' do
    context 'without evals and paths' do
      it 'raises ArgumentError' do
        expect { subject.run }.to raise_error(ArgumentError)
      end
    end

    context 'with one eval' do
      let(:options) { {:evals => ['puts "hello"']} }

      it 'executes the code' do
        expect_output_of{ subject.run }.to eq("hello\n")
      end
    end

    context 'with many evals' do
      let(:options) { {:evals => ['puts "hello"', 'puts "ciao"']} }

      it 'executes the code' do
        expect_output_of{ subject.run }.to eq("hello\nciao\n")
      end
    end
  end

  describe ':requires options' do
    context 'with an absolute path' do
      let(:options) { {:requires => [file], :evals => ['']} }
      it 'requires the file' do
        expect_output_of{ subject.run }.to eq("hi from opal!\n")
      end
    end

    context 'with a path relative to a load path' do
      let(:dir)      { File.dirname(file) }
      let(:filename) { File.basename(file) }
      let(:options)  { {:load_paths => [dir], :requires => [filename], :evals => ['']} }
      it 'requires the file' do
        expect_output_of{ subject.run }.to eq("hi from opal!\n")
      end
    end
  end

  describe ':load_paths options' do
    let(:dir)      { File.dirname(file) }
    let(:filename) { File.basename(file) }
    let(:options)  { {:load_paths => [dir], :requires => [filename], :evals => ['']} }
    it 'requires files' do
      expect_output_of{ subject.run }.to eq("hi from opal!\n")
    end
  end

  def expect_output_of
    stdout = described_class.stdout
    described_class.stdout = fake_stdout
    yield
    @output = fake_stdout.tap(&:rewind).read
    expect(@output)
  ensure
    described_class.stdout = stdout
  end
end
