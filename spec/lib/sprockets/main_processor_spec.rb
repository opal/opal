require 'lib/spec_helper'
require 'opal/sprockets/main_processor'

describe Opal::Sprockets::MainProcessor do
  let(:environment) { double(Sprockets::Environment,
    method: -> _ {}
  ) }
  let(:sprockets_input) { {
    name: "foo",
    environment: environment,
    metadata: {
      required: []
    },
  } }

  let(:ext) { 'opal_main' }

  describe %Q{with extension "#{ext}"} do
    it "is registered for '#{ext}' files" do
      expect(Sprockets.engines[ext]).to eq(described_class)
    end

    it "compiles and evaluates the template on #render" do
      input = sprockets_input.merge data: '"Hello, World!"'
      code = described_class.call(input)
      expect(code).to include(input[:data])
      expect(code).to include(%{Opal.load("#{input[:name]}")})
    end
  end

  describe '.cache_key' do
    it 'can be reset' do
      Opal::Config.arity_check_enabled = true
      old_cache_key = described_class.cache_key
      Opal::Config.arity_check_enabled = false
      Opal::Config.main_files << "foo"
      expect(described_class.cache_key).to eq(old_cache_key)
      described_class.reset_cache_key!
      expect(described_class.cache_key).not_to eq(old_cache_key)
    end
  end
end
