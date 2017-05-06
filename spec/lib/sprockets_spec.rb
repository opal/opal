require 'lib/spec_helper'
require 'opal/sprockets'

describe Opal::Sprockets do
  let(:env) { Sprockets::Environment.new }
  before { Opal.paths.each { |path| env.append_path path } }

  describe '.load_asset' do
    it 'loads the main asset' do
      code = described_class.load_asset('console')
      expect(code).to include('Opal.load("console");')
    end

    it 'marks as loaded "opal" plus all non opal assets' do
      code = described_class.load_asset('corelib/runtime')
      expect(code).to include('Opal.loaded(["opal","corelib/runtime"]);')
    end

    it 'tries to load an asset if it is registered as opal module' do
      code = described_class.load_asset('foo')
      expect(code).to include('if (Opal.modules["foo"]) Opal.load("foo");')
    end
  end

  it 'warns the user that passing an env is not needed, only once' do
    expect(described_class).to receive(:warn).once
    described_class.load_asset('foo', env)
    described_class.load_asset('foo', env)
    described_class.load_asset('foo', env)
  end

  describe '.javascript_include_tag' do
    it 'works with trailing / in the prefix' do
      code = described_class.javascript_include_tag('corelib/runtime', prefix: '/', sprockets: env, debug: false)
      expect(code).to include('src="/corelib/runtime.')
      expect(code).not_to include('//')
    end
  end
end
