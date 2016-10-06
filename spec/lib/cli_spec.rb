require 'lib/spec_helper'
require 'opal/cli'
require 'stringio'

describe Opal::CLI do
  let(:fake_stdout) { StringIO.new }
  let(:file)    { File.expand_path('../fixtures/opal_file.rb', __FILE__) }
  let(:options) { {} }
  subject(:cli) { described_class.new(options) }

  context 'with a file' do
    let(:options) { {:file => File.open(file)} }

    it 'runs the file' do
      expect_output_of{ subject.run }.to eq("hi from opal!\n")
    end

    context 'with lib_only: true' do
      let(:options) { super().merge lib_only: true }

      it 'raises ArgumentError' do
        expect{subject.run}.to raise_error(ArgumentError)
      end
    end
  end

  describe ':evals option' do
    context 'without evals and paths' do
      it 'raises ArgumentError' do
        expect { subject.run }.to raise_error(ArgumentError)
      end

      context 'with lib_only: true and opal require' do
        let(:options) { super().merge lib_only: true }

        it 'does not raise an error' do
          expect{subject.run}.not_to raise_error
        end
      end
    end

    context 'with one eval' do
      let(:options) { {:evals => ['puts "hello"']} }

      it 'executes the code' do
        expect_output_of{ subject.run }.to eq("hello\n")
      end

      context 'with lib_only: true' do
        let(:options) { super().merge lib_only: true }

        it 'raises ArgumentError' do
          expect{subject.run}.to raise_error(ArgumentError)
        end
      end
    end

    context 'with many evals' do
      let(:options) { {:evals => ['puts "hello"', 'puts "ciao"']} }

      it 'executes the code' do
        expect_output_of{ subject.run }.to eq("hello\nciao\n")
      end
    end
  end

  describe ':no_exit option' do
    context 'when false' do
      let(:options) { {no_exit: false, compile: true, evals: ['']} }
      it 'appends a Kernel#exit at the end of the source' do
        expect_output_of{ subject.run }.to include(".$exit()")
      end
    end

    context 'when true' do
      let(:options) { {no_exit: true, compile: true, evals: ['']} }
      it 'appends a Kernel#exit at the end of the source' do
        expect_output_of{ subject.run }.not_to include(".$exit();")
      end
    end
  end

  describe ':lib_only option' do
    context 'when false' do
      let(:options) { {lib_only: false, compile: true, evals: [''], skip_opal_require: true, no_exit: true} }
      it 'appends an empty code block at the end of the source' do
        expect_output_of{ subject.run }.to include("function(Opal)")
      end
    end

    context 'when true' do
      let(:options) { {lib_only: true, compile: true, no_exit: true} }
      it 'appends code block at the end of the source' do
        expect_output_of{ subject.run }.not_to eq("\n")
      end

      context 'without any require' do
        let(:options) { {lib_only: true, compile: true, skip_opal_require: true, no_exit: true} }
        it 'raises ArgumentError' do
          expect{subject.run}.to raise_error(ArgumentError)
        end
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
        builder = cli.builder

        spec = Gem::Specification.find_by_name(gem_name)
        spec.require_paths.each do |require_path|
          require_path = File.join(spec.gem_dir, require_path)
          expect(builder.path_reader.send(:file_finder).paths).to include(require_path)
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
    let(:options)  { {:compile => true, :evals => ['puts 2342']} }

    it 'outputs the compiled javascript' do
      expect_output_of{ subject.run }.to include(".$puts(2342)")
      expect_output_of{ subject.run }.not_to include("2342\n")
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

  describe ':sexp option' do
    let(:options) { {evals: ['puts 4'], sexp: true} }
    it 'prints syntax expressions for the given code' do
      expect_output_of{ subject.run }.to eq("s(:send, nil, :puts,\n  s(:int, 4))\n")
    end
  end

  describe ':map option' do
    let(:map_path) { "#{Dir.mktmpdir 'opal-map'}/file.map" }
    let(:options)  { {map: map_path, evals: ['123']} }

    it 'sets the verbose flag (currently unused)' do
      expect_output_of{ subject.run }.to eq('')
      expect(File.read(map_path)).to include(%{"version":3})
    end
  end

  describe ':parse_comments option' do
    let(:code) do
      <<-CODE
        # multiline
        # comment
        def m
        end
      CODE
    end
    let(:options) { { parse_comments: true, evals: [code], compile: true } }

    it 'sets $$comment prop for compiled methods' do
      expect_output_of { subject.run }.to include('$$comments = ["# multiline", "# comment"]')
    end
  end

  describe ':enable_source_location' do
    let(:file) { File.expand_path('../fixtures/source_location_test.rb', __FILE__) }
    let(:options) { { enable_source_location: true, compile: true, file: File.open(file) } }

    it 'sets $$source_location prop for compiled methods' do
      expect_output_of { subject.run }.to include("source_location_test.rb', 6]")
    end
  end

  private

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
