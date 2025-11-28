require 'lib/spec_helper'
require 'opal/os'
require 'opal/builder'
require 'opal/builder/scheduler/sequential'
require 'opal/builder/scheduler/threaded'
require 'opal/fragment'
require 'tmpdir'

RSpec.describe Opal::Builder::PostProcessor do
  subject(:builder) { Opal::Builder.new(options) }
  let(:options) { {compiler_options: {cache_fragments: true}} }
  let(:postprocessors) {
    body = postprocessor_body
    Class.new(described_class) { define_method(:call, &body) }
  }

  around(:example) do |example|
    described_class.with_postprocessors(postprocessors, &example)
  end

  context "with a capturing postprocessor" do
    scratchpad = nil
    let(:postprocessor_body) {-> {
      scratchpad << [processed, builder]
      processed
    }}

    it "has an access to both processed and builder" do
      scratchpad = []
      builder.build_str("require 'opal'", "(sample)").to_s
      scratchpad.length.should be 1
      first = scratchpad.first
      first[0].should be_a Array
      first[1].should be builder
      first[0].each { |i| i.should be_a Opal::Builder::Processor }
    end
  end

  context "with a replacing postprocessor" do
    let(:postprocessor_body) {-> {
      [
        Opal::Builder::Processor::JsProcessor.new("Replaced!", "replaced.js")
      ]
    }}

    it "replaces everything in all result and source map" do
      b = builder.build_str("require 'opal'", "(sample)")
      b.to_s.should start_with "Replaced!"
      b.source_map.to_s.should include "Replaced!"
    end
  end

  context "with a fragment replacing postprocessor" do
    let(:postprocessor_body) {-> {
      processed.each do |file|
        if file.respond_to? :compiled
          compiler = file.compiled
          compiler.fragments = compiler.fragments.map do |frag|
            if frag.is_a? Opal::Fragment
              Opal::Fragment.new("Badger", frag.scope, frag.sexp)
            end
          end.compact
        end
      end
    }}

    it "replaces fragments correctly" do
      b = builder.build_str("require 'opal'", "(sample)")
      b.to_s.should include "Badger" * 1000
      # TODO: Test the source map integrity?
    end
  end
end
