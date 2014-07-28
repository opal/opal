require 'lib/spec_helper'
require 'opal/cli'
require 'stringio'

describe Opal::CLI do
  let(:fake_stdout) { StringIO.new }
  let(:file)    { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
  let(:options) { nil }
  subject(:cli) { described_class.new(options) }

  context 'with a file' do
    let(:options) { {:file => File.open(file)} }

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

  describe ':gems options' do
    context 'with a Gem name' do
      let(:dir)      { File.dirname(file) }
      let(:filename) { File.basename(file) }
      let(:gem_name) { 'mspec' }
      let(:options)  { {:gems => [gem_name], :evals => ['']} }

      it "adds the gem's lib paths to Opal.path" do
        cli.run

        spec = Gem::Specification.find_by_name(gem_name)
        spec.require_paths.each do |require_path|
          require_path = File.join(spec.gem_dir, require_path)
          expect(Opal.paths).to include(require_path)
        end
      end
    end
  end

  describe ':stubs options' do
    context 'with a stubbed file' do
      let(:dir)      { File.dirname(file) }
      let(:filename) { File.basename(file) }
      let(:stub_name) { 'an_unparsable_lib' }
      let(:options)  { {:stubs => [stub_name], :evals => ["require #{stub_name.inspect}"]} }

      it "adds the gem's lib paths to Opal.path" do
        expect_output_of{ subject.run }.to eq('')
      end
    end
  end

  describe ':verbose option' do
    let(:options)  { {:verbose => true, :evals => ['']} }

    it 'sets the verbose flag (currently unused)' do
      expect(cli.verbose).to eq(true)
    end
  end

  describe ':compile option' do
    let(:options)  { {:compile => true, :evals => ['puts 5']} }

    it 'outputs the compiled javascript' do
      expect_output_of{ subject.run }.to include(".$puts(5)")
      expect_output_of{ subject.run }.not_to include("5\n")
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
    @output, _result = output_and_result_of { yield }
    expect(@output)
  end

  def output_and_result_of
    stdout = described_class.stdout
    described_class.stdout = fake_stdout
    result = yield
    output = fake_stdout.tap(&:rewind).read
    return output, result
  ensure
    described_class.stdout = stdout
  end
end
