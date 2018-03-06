require 'lib/spec_helper'

RSpec.describe Opal::Nodes::CallNode::DependencyResolver do
  let(:compiler) { double(:compiler, dynamic_require_severity: :warning) }

  it "resolves simple strings to themselves" do
    expect(resolve s(:str, 'foo')).to eq('foo')
  end

  context "using a dynamic segment not supported" do
    it "raises a compiler error when severity is :error" do
      compiler = double(:compiler, dynamic_require_severity: :error)
      expect(compiler).to     receive(:dynamic_require_severity).once
      expect(compiler).not_to receive(:warning)
      expect(compiler).to     receive(:error).once
      described_class.new(compiler, s(:self)).resolve
    end

    it "produces a compiler warning when severity is :warning" do
      compiler = double(:compiler, dynamic_require_severity: :warning)
      expect(compiler).to     receive(:dynamic_require_severity).once
      expect(compiler).to     receive(:warning).once
      expect(compiler).not_to receive(:error)
      described_class.new(compiler, s(:self)).resolve
    end

    it "does not produce a warning when severity is :ignore" do
      compiler = double(:compiler, dynamic_require_severity: :ignore)
      expect(compiler).to     receive(:dynamic_require_severity).once
      expect(compiler).not_to receive(:warning)
      expect(compiler).not_to receive(:error)
      described_class.new(compiler, s(:self)).resolve
    end
  end

  def s(type, *children)
    ::Opal::AST::Node.new(type, children)
  end

  def resolve(sexp)
    described_class.new(compiler, sexp).resolve
  end
end
