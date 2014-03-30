require File.expand_path('../spec_helper', __FILE__)
require 'opal/new_builder'

describe Opal::NewBuilder do
  let(:filepath) { 'foo/bar.rb' }
  let(:compiled_source) { "compiled source" }
  subject(:builder) { described_class.new path_finder, compiler }
  let(:compiler) { double('compiler', :requires => requires) }
  let(:path_finder) { double('pathfinder') }

  # def find_opal_require(file)
  #   file = file.gsub(/\.rb$/, '')
  #   path = load_paths.find do |p|
  #     File.exist?(File.join(p, "#{file}.rb"))
  #   end
  #
  #   raise LoadError, "cannot find #{file.inspect} in #{load_paths.inspect}" unless path
  #   File.join(path, "#{file}.rb")
  # end

  before do
    path_finder.stub(:read).with(filepath) { "file source" }
    compiler.stub(:compile).with("file source", :file => filepath) { compiled_source }
  end

  context 'without requires' do
    let(:requires) { [] }

    it 'just delegates to Compiler#compile' do
      expect(builder.build(filepath)).to eq("compiled source")
    end
  end

  context 'with requires' do
    let(:requires) { ['foo', 'bar'] }
    let(:required_foo) { "required foo" }
    let(:required_bar) { "required bar" }

    before do
      path_finder.stub(:read).with("foo") { "foo source" }
      path_finder.stub(:read).with("bar") { "bar source" }
      compiler.stub(:compile).with("foo source", :file => "foo", :requirable => true) { required_foo }
      compiler.stub(:compile).with("bar source", :file => "bar", :requirable => true) { required_bar }
    end

    it 'includes the required files' do
      expect(builder.build(filepath)).to eq("#{required_foo}#{required_bar}#{compiled_source}")
    end
  end
end
