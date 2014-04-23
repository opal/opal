require 'cli/spec_helper'

describe Opal::Nodes::CallNode::DependencyResolver do
  let(:compiler) { double(:compiler, :dynamic_require_severity => :none) }

  it "resolves simple strings to themselves" do
    expect(resolve s(:str, 'foo')).to eq('foo')
  end

  context "using a dynamic segment not supported" do
    it "raises a compiler error when severity is :error" do
      compiler = double(:compiler, :dynamic_require_severity => :error)
      expect(compiler).to receive(:error).once
      expect(compiler).to receive(:dynamic_require_severity).once
      described_class.new(compiler, s(:self)).resolve
    end

    it "produces a compiler warning when severity is :warning" do
      compiler = double(:compiler, :dynamic_require_severity => :warning)
      expect(compiler).to receive(:warning).once
      expect(compiler).to receive(:dynamic_require_severity).once
      described_class.new(compiler, s(:self)).resolve
    end

    it "does not produce a warning or error for other options" do
      compiler = double(:compiler, :dynamic_require_severity => :foo)
      expect(compiler).to_not receive(:warning)
      expect(compiler).to_not receive(:error)
      described_class.new(compiler, s(:self)).resolve
    end
  end

  def s(*parts)
    Opal::Sexp.new(parts)
  end

  def resolve(sexp)
    described_class.new(compiler, sexp).resolve
  end
end
