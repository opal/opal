require 'lib/spec_helper'
require 'opal/sprockets/environment'

describe Opal::Environment do
  let(:env) { described_class.new }
  let(:logical_path) { 'sprockets_file' }

  before { env.append_path File.expand_path('../../fixtures/', __FILE__) }

  it 'compiles Ruby to JS' do
    expect(env[logical_path].source).to include('$puts(')
    expect(env[logical_path+'.js'].source).to include('$puts(')
  end

  describe 'require_tree sprockets directive' do
    it 'is still supported' do
      source = env['sprockets_require_tree_test'].source
      expect(source).to include('required_file1')
      expect(source).to include('required_file2')
    end
  end

end
