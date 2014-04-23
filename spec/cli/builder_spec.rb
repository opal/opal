require 'cli/spec_helper'
require 'opal/builder'
require 'cli/shared/path_reader_shared'

describe Opal::Builder do
  subject(:builder)     { described_class.new(options) }

  let(:options) { {
     :path_reader        => path_reader,
     :compiler_class     => compiler_class,
     :erb_compiler_class => erb_compiler_class,
  } }

  let(:path_reader)         { double('path reader') }
  let(:compiler_class)      { double('compiler_class') }
  let(:erb_compiler_class)  { double('erb_compiler_class') }

  let(:filepath)        { 'foo/bar.rb' }
  let(:compiled_source) { "compiled source" }
  let(:compiler)        { double('compiler', :requires => requires) }
  let(:source)          { 'file source' }
  let(:requires)        { [] }

  before do
    path_reader.stub(:read) { |path| raise ArgumentError, path }
    path_reader.stub(:read).with(filepath) { source }
    compiler_class.stub(:new).with(source, :file => filepath) do
      double('compiler', :compile => nil, :result => compiled_source, :requires => requires)
    end
  end

  it 'can build from a string' do
    expect(builder.build_str(source, filepath)).to eq(compiled_source)
  end

  context 'without requires' do
    include_examples :path_reader do
      let(:path) {filepath}
      let(:contents) {"file source"}
    end

    it 'just delegates to Compiler#compile' do
      expect(builder.build(filepath)).to eq("compiled source")
    end
  end

  context 'with requires' do
    let(:requires) { [foo_path, bar_path] }
    let(:foo_path) { 'foo' }
    let(:bar_path) { 'bar' }
    let(:required_foo) { "required foo" }
    let(:required_bar) { "required bar" }
    let(:foo_contents) { "foo source" }
    let(:bar_contents) { "bar source" }

    before do
      path_reader.stub(:read).with(foo_path) { foo_contents }
      path_reader.stub(:read).with(bar_path) { bar_contents }
      foo_compiler = double('compiler', :compile => nil, :result => required_foo, :requires => [])
      bar_compiler = double('compiler', :compile => nil, :result => required_bar, :requires => [])
      compiler_class.stub(:new).with(foo_contents, :file => foo_path, :requirable => true) { foo_compiler }
      compiler_class.stub(:new).with(bar_contents, :file => bar_path, :requirable => true) { bar_compiler }
    end

    it 'includes the required files' do
      expect(builder.build(filepath)).to eq([
        required_foo,
        required_bar,
        compiled_source,
      ].join("\n"))
    end

    context 'with prerequired files' do
      let(:prerequired) { [foo_path] }

      it 'skips their compilation' do
        expect(builder.build(filepath, prerequired)).to eq([
          required_bar,
          compiled_source,
        ].join("\n"))
      end
    end

    context 'with a stubbed file' do
      let(:foo_stubbed) { 'foo stubbed' }

      before do
        options.merge! stubbed_files: [foo_path]
        foo_compiler = double('compiler', :compile => nil, :result => foo_stubbed, :requires => [])
        compiler_class.stub(:new).with('', :file => foo_path, :requirable => true) { foo_compiler }
      end

      it 'returns an empty source' do
        expect(builder.build(filepath)).to eq([
          foo_stubbed,
          required_bar,
          compiled_source,
        ].join("\n"))
      end
    end


    include_examples :path_reader do
      let(:path) {'foo'}
      let(:contents) { foo_contents }
    end

    context 'requiring a js file' do
      let(:foo_path) { 'foo.js' }
      let(:foo_stubbed) { 'foo stubbed' }

      before do
        foo_compiler = double('compiler', :compile => nil, :result => foo_stubbed, :requires => [])
        compiler_class.stub(:new).with('', :file => foo_path, :requirable => true) { foo_compiler }
      end

      it 'includes the JS contents (as is)' do
        expect(builder.build(filepath)).to eq([
          foo_contents,
          foo_stubbed,
          required_bar,
          compiled_source,
        ].join("\n"))
      end
    end

    context 'requiring an ERB template' do
      let(:foo_path) { 'foo.opalerb' }
      let(:compiled_template) { 'foo template' }
      let(:erb_lib) { 'erb lib' }
      let(:required_erb_lib) { 'compiled erb lib' }
      let(:erb_compiler) { double('erb compiler') }
      let(:prepared_foo_contents) { double('prepared_foo_contents') }

      before do
        path_reader.stub(:read).with('erb') { erb_lib }
        erb_lib_compiler = double('compiler', :compile => nil, :result => required_erb_lib, :requires => ['erb'])
        compiler_class.stub(:new).with(erb_lib, :file => 'erb', :requirable => true) { erb_lib_compiler }

        erb_template_compiler = double('compiler', :compile => nil, :result => compiled_template, :requires => ['erb'])
        compiler_class.stub(:new).with(prepared_foo_contents, :file => foo_path, :requirable => true) { erb_template_compiler }

        erb_compiler_class.stub(:new).with(foo_contents, foo_path) { erb_compiler }
        erb_compiler.stub(:prepared_source) { prepared_foo_contents }
      end

      it 'includes the compiled ERB template along with the "erb" stdlib' do
        expect(builder.build(filepath)).to eq([
          required_erb_lib,
          compiled_template,
          required_bar,
          compiled_source,
        ].join("\n"))
      end
    end

  end

end
