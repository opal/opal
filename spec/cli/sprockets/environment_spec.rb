require 'cli/spec_helper'
require 'opal/sprockets/environment'

describe Opal::Environment do
  let(:env) { described_class.new }
  let(:logical_path) { 'sprockets_file' }

  before { env.append_path File.expand_path('../../fixtures/', __FILE__) }

  it 'compiles Ruby to JS' do
    expect(env[logical_path].source).to include('$puts(')
    expect(env[logical_path+'.js'].source).to include('$puts(')
  end
end
