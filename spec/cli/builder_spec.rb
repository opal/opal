require 'cli/spec_helper'
require 'opal/builder'
require 'cli/shared/path_reader_shared'

describe Opal::Builder do
  subject(:builder) { described_class.new(options) }
  let(:options) { Hash.new }

  it 'compiles opal' do
    expect(builder.build('opal').to_s).to match('(Opal);')
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
end
