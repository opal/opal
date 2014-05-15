require 'cli/spec_helper'
require 'cli/shared/path_reader_shared'
require 'opal/sprockets/path_reader'

describe Opal::Sprockets::PathReader do
  subject(:path_reader) { described_class.new(env, context) }

  let(:env) { Opal::Environment.new }

  # TODO: use stubs and expect calls on #depend_on and #depend_on_asset
  let(:context) { env.context_class.new(env, 'foo', Pathname('bar/baz/foo.js')) }

  let(:logical_path) { 'sprockets_file' }
  let(:fixtures_dir) { File.expand_path('../../fixtures/', __FILE__) }
  let(:full_path) { File.join(fixtures_dir, logical_path+'.js.rb') }
  let(:contents) { File.read(full_path) }

  before { env.append_path fixtures_dir }

  include_examples :path_reader do
    let(:path) { logical_path }
  end

  it 'can read stuff from sprockets env' do
    expect(path_reader.read(logical_path)).to eq(contents)
  end
end
