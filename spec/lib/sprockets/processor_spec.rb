require 'lib/spec_helper'
require 'opal/sprockets/processor'

describe Opal::Processor do
  let(:pathname) { Pathname("/Code/app/mylib/opal/foo.#{ext}") }
  let(:environment) { double(Sprockets::Environment,
    cache: nil,
    :[] => nil,
    resolve: pathname.expand_path.to_s,
    engines: double(keys: %w[.rb .js .opal]),
  ) }
  let(:sprockets_context) { double(Sprockets::Context,
    logical_path: "foo.#{ext}",
    environment: environment,
    pathname: pathname,
    filename: pathname.to_s,
    root_path: '/Code/app/mylib',
    is_a?: true,
  ) }

  %w[.rb .opal].each do |ext|
    let(:ext) { ext }

    describe %Q{with extension "#{ext}"} do
      it "is registered for '#{ext}' files" do
        expect(Sprockets.engines[ext]).to eq(described_class)
      end

      it "compiles and evaluates the template on #render" do
        template = described_class.new { |t| "puts 'Hello, World!'\n" }
        expect(template.render(sprockets_context)).to include('"Hello, World!"')
      end
    end
  end

  describe '.stubbed_files' do
    around do |e|
      described_class.stubbed_files.clear
      e.run
      described_class.stubbed_files.clear
    end

    let(:stubbed_file) { 'foo' }
    let(:template) { described_class.new { |t| "require #{stubbed_file.inspect}" } }

    it 'usually require files' do
      sprockets_context.should_receive(:require_asset).with(stubbed_file)
      template.render(sprockets_context)
    end

    it 'skips require of stubbed file' do
      described_class.stub_file stubbed_file
      sprockets_context.should_not_receive(:require_asset).with(stubbed_file)
      template.render(sprockets_context)
    end

    it 'marks a stubbed file as loaded' do
      described_class.stub_file stubbed_file
      asset = double(dependencies: [], pathname: Pathname('bar'), logical_path: 'bar')
      environment.stub(:[]).with('bar.js') { asset }
      environment.stub(:engines) { {'.rb' => described_class, '.opal' => described_class} }

      code = described_class.load_asset_code(environment, 'bar')
      code.should match stubbed_file
    end
  end

  describe '.cache_key' do
    it 'can be reset' do
      Opal::Config.arity_check_enabled = true
      old_cache_key = described_class.cache_key
      Opal::Config.arity_check_enabled = false
      expect(described_class.cache_key).to eq(old_cache_key)
      described_class.reset_cache_key!
      expect(described_class.cache_key).not_to eq(old_cache_key)
    end
  end
end
