require 'lib/spec_helper'
require 'opal/cli_runners'

RSpec.describe Opal::CliRunners do
  around do |example|
    original_register = described_class.instance_variable_get :@register
    example.run
    described_class.instance_variable_set :@register, original_register
  end

  describe '.alias_runner' do
    it 'aliases between runner names' do
      expect(described_class[:node]).to eq(described_class[:nodejs])
    end
  end
end
