require 'lib/spec_helper'
require 'opal/config'

describe Opal::Config do
  before { described_class.reset! }
  after { described_class.reset! }

  describe '.default_config' do
    it 'is new each time' do
      default_config1 = described_class.default_config
      default_config2 = described_class.default_config
      expect(default_config1).to eq(default_config2)
      expect(default_config1).not_to equal(default_config2)
      described_class.default_config[:stubbed_files] << :foo
      expect(described_class.default_config[:stubbed_files]).to eq(Set.new)
    end
  end

  it 'has expected default values' do
    expect(described_class.method_missing_enabled).to   eq(true)
    expect(described_class.const_missing_enabled).to    eq(true)
    expect(described_class.arity_check_enabled).to      eq(false)
    expect(described_class.freezing_stubs_enabled).to   eq(true)
    expect(described_class.tainting_stubs_enabled).to   eq(true)
    expect(described_class.dynamic_require_severity).to eq(:warning)
    expect(described_class.irb_enabled).to              eq(false)
    expect(described_class.inline_operators_enabled).to eq(true)
    expect(described_class.source_map_enabled).to       eq(true)
    expect(described_class.stubbed_files).to            eq(Set.new)
  end

  it 'raises an ArgumentError if provided with an unexpected value' do
    expect{ described_class.method_missing_enabled   = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.const_missing_enabled    = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.arity_check_enabled      = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.freezing_stubs_enabled   = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.tainting_stubs_enabled   = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.dynamic_require_severity = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.irb_enabled              = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.inline_operators_enabled = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.source_map_enabled       = :foobar }.to raise_error(ArgumentError)
    expect{ described_class.stubbed_files            = :foobar }.to raise_error(ArgumentError)
  end

  it 'does not raises errors if provided with an expected value' do
    expect{ described_class.arity_check_enabled      = false }.not_to raise_error
    expect(described_class.arity_check_enabled).to eq(false)

    expect{ described_class.arity_check_enabled      = true }.not_to raise_error
    expect(described_class.arity_check_enabled).to eq(true)

    expect{ described_class.const_missing_enabled    = false }.not_to raise_error
    expect(described_class.const_missing_enabled).to eq(false)

    expect{ described_class.const_missing_enabled    = true }.not_to raise_error
    expect(described_class.const_missing_enabled).to eq(true)

    expect{ described_class.dynamic_require_severity = :error }.not_to raise_error
    expect(described_class.dynamic_require_severity).to eq(:error)

    expect{ described_class.dynamic_require_severity = :ignore }.not_to raise_error
    expect(described_class.dynamic_require_severity).to eq(:ignore)

    expect{ described_class.dynamic_require_severity = :warning }.not_to raise_error
    expect(described_class.dynamic_require_severity).to eq(:warning)

    expect{ described_class.freezing_stubs_enabled   = false }.not_to raise_error
    expect(described_class.freezing_stubs_enabled).to eq(false)

    expect{ described_class.freezing_stubs_enabled   = true }.not_to raise_error
    expect(described_class.freezing_stubs_enabled).to eq(true)

    expect{ described_class.inline_operators_enabled = false }.not_to raise_error
    expect(described_class.inline_operators_enabled).to eq(false)

    expect{ described_class.inline_operators_enabled = true }.not_to raise_error
    expect(described_class.inline_operators_enabled).to eq(true)

    expect{ described_class.irb_enabled              = false }.not_to raise_error
    expect(described_class.irb_enabled).to eq(false)

    expect{ described_class.irb_enabled              = true }.not_to raise_error
    expect(described_class.irb_enabled).to eq(true)

    expect{ described_class.method_missing_enabled   = false }.not_to raise_error
    expect(described_class.method_missing_enabled).to eq(false)

    expect{ described_class.method_missing_enabled   = true }.not_to raise_error
    expect(described_class.method_missing_enabled).to eq(true)

    expect{ described_class.source_map_enabled       = false }.not_to raise_error
    expect(described_class.source_map_enabled).to eq(false)

    expect{ described_class.source_map_enabled       = true }.not_to raise_error
    expect(described_class.source_map_enabled).to eq(true)

    expect{ described_class.stubbed_files            << 'foo' }.not_to raise_error
    expect(described_class.stubbed_files).to eq(['foo'].to_set)

    expect{ described_class.stubbed_files            = %w[foo bar].to_set }.not_to raise_error
    expect(described_class.stubbed_files).to eq(%w[foo bar].to_set)

    expect{ described_class.tainting_stubs_enabled   = false }.not_to raise_error
    expect(described_class.tainting_stubs_enabled).to eq(false)

    expect{ described_class.tainting_stubs_enabled   = true }.not_to raise_error
    expect(described_class.tainting_stubs_enabled).to eq(true)

  end
end
