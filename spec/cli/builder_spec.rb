require 'cli/spec_helper'
require 'opal/builder'
require 'cli/shared/path_reader_shared'

describe Opal::Builder do
  subject(:builder) { described_class.new(options) }
  let(:options) { Hash.new }

  it 'compiles opal' do
    expect(builder.build('opal').to_s).to match('(Opal);')
  end

  describe 'stubs' do
    let(:options) { {stubs: ['foo'], } }
    it 'compiles them as empty files' do
      source = 'require "foo"'

      expect(builder.default_processor).to receive('new').once do |*args|
        expect(args.first).to eq(source)
      end.and_call_original

      expect(builder.default_processor).to receive('new').once do |*args|
        expect(args.first).to eq('')
      end.and_call_original

      builder.build_str(source, 'bar.rb')
    end
  end
end
