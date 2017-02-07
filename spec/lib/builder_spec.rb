require 'lib/spec_helper'
require 'opal/builder'
require 'lib/shared/path_reader_shared'

describe Opal::Builder do
  subject(:builder) { described_class.new(options) }
  let(:options) { {} }

  it 'compiles opal' do
    expect(builder.build('opal').to_s).to match('(Opal);')
  end

  it 'respect #require_tree calls' do
    builder.append_paths(File.expand_path('..', __FILE__))
    expect(builder.build('fixtures/require_tree_test').to_s).to include('Opal.modules["fixtures/required_tree_test/required_file1"]')
  end

  describe ':stubs' do
    let(:options) { {stubs: ['foo']} }

    it 'compiles them as empty files' do
      source = 'require "foo"'
      expect(builder.default_processor).to receive('new').with(source, anything, anything).once.and_call_original
      expect(builder.default_processor).to receive('new').with('',     anything, anything).once.and_call_original

      builder.build_str(source, 'bar.rb')
    end
  end

  describe ':prerequired' do
    let(:options) { {prerequired: ['foo']} }

    it 'compiles them as empty files' do
      source = 'require "foo"'
      builder.build_str(source, 'bar.rb')
    end
  end

  describe ':preload' do
    let(:options) { {preload: ['base64']} }

    it 'compiles them as empty files' do
      source = 'puts 5'
      expect(builder.default_processor).to receive('new').with(anything, 'base64', anything).once.and_call_original
      expect(builder.default_processor).to receive('new').with(source, anything, anything).once.and_call_original

      builder.build_str(source, 'bar.rb')
    end
  end

  describe 'dup' do
    it 'duplicates internal structures' do
      b2 = builder.dup
      b2.should_not equal(builder)
      [:stubs, :preload, :processors, :path_reader, :prerequired, :compiler_options, :processed].each do |m|
        b2.send(m).should_not equal(builder.send(m))
      end
    end
  end

  describe 'requiring a native .js file' do
    it 'can be required without specifying extension' do
      builder.build_str('require "corelib/runtime"', 'foo')
      expect(builder.to_s).to start_with('(function(undefined)')
    end

    it 'can be required specifying extension' do
      builder.build_str('require "corelib/runtime.js"', 'foo')
      expect(builder.to_s).to start_with('(function(undefined)')
    end
  end

  it 'defaults config from Opal::Config' do
    Opal::Config.arity_check_enabled = false
    expect(Opal::Config.arity_check_enabled).to eq(false)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(false)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).not_to include('TMP_foo_1.$$parameters = []')

    Opal::Config.arity_check_enabled = true
    expect(Opal::Config.arity_check_enabled).to eq(true)
    expect(Opal::Config.compiler_options[:arity_check]).to eq(true)
    builder = described_class.new
    builder.build_str('def foo; end', 'foo')
    expect(builder.to_s).to include('TMP_foo_1.$$parameters = []')
  end

end
