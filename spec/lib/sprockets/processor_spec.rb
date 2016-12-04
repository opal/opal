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
      config.stubbed_files.clear
      e.run
      config.stubbed_files.clear
    end

    let(:stubbed_file) { 'foo' }
    let(:template) { described_class.new { |t| "require #{stubbed_file.inspect}" } }
    let(:config) { Opal::Config }

    it 'usually require files' do
      expect(sprockets_context).to receive(:require_asset).with(stubbed_file)
      template.render(sprockets_context)
    end

    it 'skips require of stubbed file' do
      config.stubbed_files << stubbed_file.to_s
      expect(sprockets_context).not_to receive(:require_asset).with(stubbed_file)
      template.render(sprockets_context)
    end

    it 'marks a stubbed file as loaded' do
      config.stubbed_files << stubbed_file.to_s
      asset = double(dependencies: [], pathname: Pathname('bar'), logical_path: 'bar')
      environment.stub(:[]).with('bar.js') { asset }
      environment.stub(:engines) { {'.rb' => described_class, '.opal' => described_class} }

      code = ::Opal::Sprockets.load_asset('bar', environment)
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

  describe 'main files' do
    fit 'does not need loading code' do
      Opal::Sprockets.main << 'sprockets_main_file'
      Opal::Sprockets.main << 'required_tree_test/required_file1'

      Opal::Processor.reset_cache_key!
      env = ::Sprockets::Environment.new
      (Opal.paths + ["#{__dir__}/../fixtures"]).each {|path| env.append_path path}


      result = env['sprockets_main_file'].to_s
      expect(result).to include('Opal.load("sprockets_main_file");')
      expect(result).to include('Opal.loaded("required_file");')
      expect(result).not_to include('Opal.loaded("no_requires");')

      result = env['no_requires'].to_s
      expect(result).not_to include('Opal.loaded("no_requires");')
      expect(result).not_to include('Opal.load("sprockets_main_file");')
      expect(result).not_to include('Opal.loaded("required_file");')

      result = env['complex_sprockets'].to_s
      expect(result).to include('Opal.load("required_tree_test/required_file1");')
      expect(result).to include('Opal.loaded("no_requires");')
      expect(result).not_to include('Opal.loaded("required_file");')

      expect(Opal::Sprockets.javascript_include_tag('sprockets_main_file', env)).not_to include('Opal.load')
    end
  end
end
