require 'cli/spec_helper'
require 'opal/builder'
require 'cli/shared/path_reader_shared'

module CompilerClassMocking
  def result
    super
    compiled, _requires = __result__
    @options[:requirable] ? CompilerClassMocking.requirable(compiled) : compiled
  end

  def requires
    super
    _compiled, requires = __result__
    requires
  end

  def __result__
    results = CompilerClassMocking.results
    results[@source] ||
      raise(ArgumentError, "unregistered source: #{@source.inspect} in #{results.inspect}")
  end

  attr_reader :options

  def inspect
    super + ' (CompilerClassMocking)'
  end

  # Singleton Methods

  def self.register_result_for(source, result, requires = [])
    results[source] = [result, requires]
  end

  # Wraps source
  def self.requirable(source)
    "requirable(#{source})"
  end

  def self.results
    @results ||= {}
  end

  def self.reset!
    @results = nil
  end
end

describe Opal::Builder do
  subject(:builder)     { described_class.new(options) }

  let(:options) { {
     :path_reader        => path_reader,
     :compiler_class     => compiler_class,
     :erb_compiler_class => erb_compiler_class,
  } }

  let(:path_reader)         { double('path reader') }
  let(:compiler_class)      { Class.new(Opal::Compiler) }
  let(:erb_compiler_class)  { Opal::ERB::Compiler }

  let(:filepath)        { 'foo/bar.rb' }
  let(:compiled_source) { "compiled source" }
  let(:compiler)        { double('compiler', :requires => requires) }
  let(:source)          { 'file source' }
  let(:requires)        { [] }

  before do
    CompilerClassMocking.reset!
    compiler_class.class_eval { include CompilerClassMocking }
    path_reader.stub(:read) { |path| raise ArgumentError, "Please stub some contents for #{path.inspect}" }
    path_reader.stub(:read).with(filepath) { source }
    CompilerClassMocking.register_result_for(source, compiled_source, requires)
  end

  it 'can build from a string' do
    expect(builder.build_str(source, filepath)).to eq(compiled_source)
  end

  context 'without requires' do
    include_examples :path_reader do
      let(:path) {filepath}
      let(:contents) {source}
    end

    it 'just delegates to Compiler#compile' do
      expect(builder.build(filepath)).to eq(compiled_source)
    end
  end

  context 'with requires' do
    let(:requires) { [foo_path, bar_path] }
    let(:foo_path) { 'foo' }
    let(:bar_path) { 'bar' }
    let(:compiled_foo) { "compiled foo" }
    let(:compiled_bar) { "compiled bar" }
    let(:foo_contents) { "foo source" }
    let(:bar_contents) { "bar source" }

    before do
      path_reader.stub(:read).with(foo_path) { foo_contents }
      path_reader.stub(:read).with(bar_path) { bar_contents }
      CompilerClassMocking.register_result_for(foo_contents, compiled_foo)
      CompilerClassMocking.register_result_for(bar_contents, compiled_bar)
    end

    it 'includes the required files' do
      expect(builder.build(filepath)).to eq([
        requirable(compiled_foo),
        requirable(compiled_bar),
        compiled_source,
      ].join("\n"))
    end

    context 'with prerequired files' do
      let(:prerequired) { [foo_path] }

      it 'skips their compilation' do
        expect(builder.build(filepath, :prerequired => prerequired)).to eq([
          requirable(compiled_bar),
          compiled_source,
        ].join("\n"))
      end
    end

    context 'with a stubbed file' do
      let(:stubbed_contents)      { 'stubbed_contents' }
      let(:stubbed_at_initialize) { 'stubbed_at_initialize' }
      let(:stubbed_at_build)      { 'stubbed_at_build' }
      let(:requires) { [stubbed_at_build, bar_path, stubbed_at_initialize] }

      before do
        options.merge! :stubbed_files => [stubbed_at_initialize]
        CompilerClassMocking.register_result_for('', stubbed_contents)
      end

      it 'returns an empty source' do
        expect(builder.build(filepath, :stubbed_files => [stubbed_at_build])).to eq([
          requirable(stubbed_contents),
          requirable(compiled_bar),
          requirable(stubbed_contents),
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
        CompilerClassMocking.register_result_for(foo_path, compiled_foo)
        CompilerClassMocking.register_result_for('', foo_stubbed)
      end

      it 'includes the JS contents (as is)' do
        expect(builder.build(filepath)).to eq([
          foo_contents,
          requirable(foo_stubbed),
          requirable(compiled_bar),
          compiled_source,
        ].join("\n"))
      end
    end

    context 'requiring an ERB template' do
      let(:foo_template_path) { 'foo.opalerb' }
      let(:prepared_template) { 'prepared foo template' }
      let(:requires) { [foo_template_path] }
      let(:compiled_template) { 'foo template' }
      let(:erb_lib) { 'erb lib' }
      let(:compiled_erb_lib) { 'compiled erb lib' }
      let(:erb_compiler) { double('erb compiler') }
      let(:prepared_foo_contents) { double('prepared_foo_contents') }

      before do
        CompilerClassMocking.register_result_for(erb_lib, compiled_erb_lib)
        CompilerClassMocking.register_result_for(prepared_template, compiled_template, ['erb'])
        path_reader.stub(:read).with('erb') { erb_lib }
        path_reader.stub(:read).with(foo_template_path) { foo_contents }
        allow_any_instance_of(erb_compiler_class).to receive(:prepared_source) { prepared_template }
      end

      it 'includes the compiled ERB template along with the "erb" stdlib' do
        expect(builder.build(filepath)).to eq([
          requirable(compiled_erb_lib),
          requirable(compiled_template),
          compiled_source,
        ].join("\n"))
      end
    end

  end

  def requirable(source)
    CompilerClassMocking.requirable(source)
  end
end
