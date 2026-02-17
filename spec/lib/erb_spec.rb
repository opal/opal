require 'lib/spec_helper'
require 'opal/erb'

RSpec.describe Opal::ERB do
  describe '.compile' do
    it 'wraps the compiled code in Template.new with the file name' do
      result = described_class.compile('<span>hi</span>', 'test.opalerb')
      expect(result).to include("$$('Template'), 'new', [\"test\"]")
    end
  end

  describe Opal::ERB::Compiler do
    subject(:compiler) { described_class.new('', 'template.opalerb') }

    it '#fix_quotes escapes escaped quotes' do
      expect(compiler.fix_quotes('\\"foo\\"')).to eq('\\\\"foo\\\\"')
    end

    it '#require_erb prefixes the source with require' do
      expect(compiler.require_erb('body')).to eq('require "erb";body')
    end

    it '#find_contents replaces <%= %> with append call' do
      result = compiler.find_contents('<%= 1 + 2 %>')
      expect(result).to include('output_buffer.append=( 1 + 2 )')
    end

    it '#find_code replaces <% %> with inline code' do
      result = compiler.find_code('<% a = 1 %>')
      expect(result).to include('a = 1')
    end

    it '#wrap_compiled strips the .opalerb extension' do
      expect(compiler.wrap_compiled('out')).to start_with("Template.new('template')")
    end
  end
end
