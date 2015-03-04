require 'lib/spec_helper'
require 'lib/shared/path_reader_shared'
require 'opal/sprockets/path_reader'

describe Opal::Sprockets::PathReader do
  let(:env) { Sprockets::Environment.new }
  let(:context) { double('context', depend_on: nil, depend_on_asset: nil) }
  let(:contents) { File.read(full_path) }
  let(:full_path) { fixtures_dir.join(logical_path+'.js.rb') }
  let(:logical_path) { 'sprockets_file' }
  let(:fixtures_dir) { Pathname('../../fixtures/').expand_path(__FILE__) }

  subject(:path_reader) { described_class.new(env, context) }

  before do
    Opal.paths.each {|p| env.append_path(p)}
    env.append_path fixtures_dir
  end

  include_examples :path_reader do
    let(:path) { logical_path }
  end

  it 'can read stuff from sprockets env' do
    expect(path_reader.read(logical_path)).to eq(contents)
  end

  it 'reads js files processing their directives' do
    path              = 'file_with_directives.js'
    full_path         = fixtures_dir.join(path)
    required_contents = File.read(fixtures_dir.join('required_file.js')).strip
    read_contents     = path_reader.read(path)
    actual_contents   = full_path.read

    expect(actual_contents).to include('//= require')
    expect(read_contents).not_to include('//= require')

    expect(read_contents).to include(required_contents)
    expect(actual_contents).not_to include(required_contents)
  end
end
