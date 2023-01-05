require 'lib/spec_helper'
require 'open3'
require 'opal/os'

RSpec.describe "rake dist" do
  before :all do
    system "rake dist >#{Opal::OS.dev_null}"
  end

  def run_with_node(code, precode:, requires:)
    requires = requires.map do |i|
      "require('./build/#{i}');"
    end.join

    code = "#{requires};#{precode};console.log(#{code});"

    stdout, _, status = Open3.capture3('node', '-e', code)

    expect(status).to eq(0)

    stdout.chomp
  end

  let(:output) { run_with_node(code, precode: precode, requires: requires) }
  let(:requires) { ['opal'] }
  let(:precode) { '' }
  let(:code) { 'typeof Opal' }

  it 'should provide a working Opal environment' do
    expect(output).to eq('object')
  end

  context do
    let(:requires) { ['opal/mini'] }

    it 'should provide a working Opal mini environment' do
      expect(output).to eq('object')
    end
  end

  context do
    let(:requires) { ['opal', 'opal/full'] }
    let(:precode) { 'Opal.require("corelib/pattern_matching")' }
    let(:code) { 'typeof Opal.PatternMatching' }

    it 'should provide a working Opal full environment' do
      expect(output).to eq('function')
    end
  end

  context do
    let(:requires) { %w[opal opal-replutils] }
    let(:code) { 'typeof Opal.REPLUtils' }

    it 'should not require requirable files by default' do
      expect(output).to eq('undefined')
    end
  end

  context do
    let(:requires) { %w[opal opal-replutils] }
    let(:precode) { 'Opal.require("opal-replutils")' }
    let(:code) { 'typeof Opal.REPLUtils' }

    it 'should allow user to require requirable files to provide missing functionality' do
      expect(output).to eq('function')
    end
  end
end
