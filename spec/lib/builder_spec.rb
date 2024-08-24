require 'lib/spec_helper'
require 'opal/builder'
require 'opal/builder/scheduler/sequential'
require 'tmpdir'

RSpec.describe Opal::Builder do
  subject(:builder) { described_class.new(options) }
  let(:options) { {} }
  let(:ruby_processor) { Opal::Builder::Processor::RubyProcessor }

  def temporarily_with_sequential_scheduler(&block)
    previous = Opal.builder_scheduler
    Opal.builder_scheduler = Opal::Builder::Scheduler::Sequential
    yield
    Opal.builder_scheduler = previous
  end

  it 'compiles opal' do
    expect(builder.build('opal').to_s).to match('(Opal);')
  end

  it 'respect #require_tree calls' do
    builder.append_paths(File.expand_path('..', __FILE__))
    expect(builder.build('fixtures/require_tree_test').to_s).to include('Opal.modules["fixtures/required_tree_test/required_file1"]')
  end

  describe ':stubs' do
    let(:options) { {stubs: ['foo']} }

    around(:each) { |example| temporarily_with_sequential_scheduler(&example) }

    it 'compiles them as empty files' do
      source = 'require "foo"'
      expect(ruby_processor).to receive('new').with(source, anything, anything, anything).once.and_call_original
      expect(ruby_processor).to receive('new').with('',     anything, anything, anything).once.and_call_original

      builder.build_str(source, 'bar.rb')
    end
  end

  describe 'dup' do
    it 'duplicates internal structures' do
      b2 = builder.dup
      b2.should_not equal(builder)
      [:stubs, :processors, :path_reader, :compiler_options, :processed].each do |m|
        b2.send(m).should_not equal(builder.send(m))
      end
    end

    it 'processes dependencies correctly' do
      b2 = builder
      2.times do
        b2 = b2.dup
        source = 'require "json"'
        b2.build_str(source, 'bar.rb')
        b2.to_s.should include("$to_json")
      end
    end
  end

  describe 'requiring a native .js file' do
    it 'can be required without specifying extension' do
      builder.build_str('require "corelib/runtime"', 'foo')
      expect(builder.to_s).to start_with("(function(global_object)")
    end

    it 'can be required specifying extension' do
      builder.build_str('require "corelib/runtime.js"', 'foo')
      expect(builder.to_s).to start_with("(function(global_object)")
    end
  end

  it 'defaults config from Opal::Config' do
    Opal::Config.arity_check_enabled = false
    expect(Opal::Config.arity_check_enabled).to eq(false)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(false)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).not_to include('$$parameters: []')

    Opal::Config.arity_check_enabled = true
    expect(Opal::Config.arity_check_enabled).to eq(true)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(true)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).to include('$$parameters: []')
  end

  describe '#missing_require_severity' do
    around(:each) { |example| temporarily_with_sequential_scheduler(&example) }

    it 'defaults to warning' do
      expect(builder.missing_require_severity).to eq(:error)
    end

    context 'when set to :warning' do
      let(:options) { {missing_require_severity: :warning} }
      it 'warns the user' do
        expect(builder.missing_require_severity).to eq(:warning)
        expect(builder).to receive(:warn) { |message| expect(message).to start_with(%{can't find file: "non-existen-file"}) }.at_least(1)
        builder.build_str("require 'non-existen-file'", 'foo.rb')
      end
    end

    context 'when set to :ignore' do
      let(:options) { {missing_require_severity: :ignore} }
      it 'does nothing' do
        expect(builder.missing_require_severity).to eq(:ignore)
        expect(builder).not_to receive(:warn)
        expect{ builder.build_str("require 'non-existen-file'", 'foo.rb') }.not_to raise_error
      end
    end

    context 'when set to :error' do
      let(:options) { {missing_require_severity: :error} }
      it 'raises MissingRequire' do
        expect(builder.missing_require_severity).to eq(:error)
        expect(builder).not_to receive(:warn)
        expect{ builder.build_str("require 'non-existen-file'", 'foo.rb') }.to raise_error(described_class::MissingRequire)
      end
    end
  end

  describe ':requirable' do
    it 'it uses relative paths as module names' do
      expect(builder.build('stringio', requirable: true).to_s).to include(%{Opal.modules["stringio"]})
    end
  end

  describe ':requirable' do
    it 'it uses front slash as module name' do
      expect(builder.build('opal/platform', requirable: true).to_s).to include(%{Opal.modules["opal/platform"]})
    end
  end

  describe 'output order' do
    it 'is preserved with a prefork scheduler' do
      my_builder = builder.dup
      my_builder.append_paths(File.expand_path('..', __FILE__))
      my_builder.cache = Opal::Cache::NullCache.new
      10.times do |i| # Increase entropy
        expect(
          my_builder.dup.build('fixtures/build_order').to_s.scan(/(FILE_[0-9]+)/).map(&:first)
        ).to eq(%w[
          FILE_1 FILE_2 FILE_3 FILE_4
          FILE_51 FILE_5
          FILE_61 FILE_62 FILE_63 FILE_64 FILE_6
          FILE_7
        ])
      end
    end

    it 'is preserved with a sequential scheduler' do
      temporarily_with_sequential_scheduler do
        builder.append_paths(File.expand_path('..', __FILE__))
        expect(
          builder.build('fixtures/build_order').to_s.scan(/(FILE_[0-9]+)/).map(&:first)
        ).to eq(%w[
          FILE_1 FILE_2 FILE_3 FILE_4
          FILE_51 FILE_5
          FILE_61 FILE_62 FILE_63 FILE_64 FILE_6
          FILE_7
        ])
      end
    end
  end

  describe 'directory mode' do
    shared_examples 'directory mode' do
      let(:options) { {compiler_options: {directory: true, esm: esm?}}}
      let(:ver) { Opal::VERSION_MAJOR_MINOR }

      it 'builds a correct directory structure' do
        Dir.mktmpdir("opal-test-") do |dir|
          builder.build('console')
          builder.compile_to_directory(dir+"/UniqueString/")

          files = Dir["#{dir}/**/*"].map { |i| i.split("/UniqueString/")[1] }.compact
          expected_files = %W[index.#{ext} opal opal/#{ver} opal/#{ver}/console.#{ext}
                              opal/#{ver}/console.map opal/#{ver}/native.#{ext} opal/#{ver}/native.map
                              opal/src opal/src/console.rb opal/src/native.rb]
          expected_files << 'index.html' if esm?
          expect(files.sort).to eq(expected_files.sort)
        end
      end

      it 'builds a single file if requested' do
        builder.build('console')
        file = builder.compile_to_directory(single_file: "opal/src/console.rb")
        expect(file).to eq(File.binread("#{__dir__}/../../stdlib/console.rb"))
      end
    end

    context 'with ESM enabled' do
      let(:esm?) { true }
      let(:ext) { "mjs" }
      include_examples 'directory mode'
    end

    context 'with ESM disabled' do
      let(:esm?) { false }
      let(:ext) { "js" }
      include_examples 'directory mode'
    end
  end
end
