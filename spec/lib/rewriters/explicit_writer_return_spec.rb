require 'lib/spec_helper'

describe Opal::Rewriters::ExplicitWriterReturn do
  def s(type, *children)
    ::Parser::AST::Node.new(type, children)
  end

  let(:rewriter) { Opal::Rewriters::ExplicitWriterReturn.new }
  let(:processed) { rewriter.process(input) }

  def expect_rewritten(sexp)
    processed = rewriter.process(sexp)
    expect(processed)
  end

  def expect_no_rewriting_for(sexp)
    expect_rewritten(sexp).to eq(sexp)
  end

  let(:receiver) do
    # self.a
    s(:send, nil, :a)
  end

  let(:single_argument) do
    # self.c
    s(:send, nil, :c)
  end

  let(:multiple_arguments) do
    # [self.d, self.e]
    s(:array,
      s(:send, nil, :d),
      s(:send, nil, :e)
    )
  end

  let(:constant_returner) do
    # $writer[$writer.length - 1]
    s(:jsattr,
      s(:lvar, "$writer"),
      s(:send, s(:jsattr, s(:lvar, "$writer"), s(:str, "length")), :-, s(:int, 1))
    )
  end

  shared_examples 'always returns a temporary argument' do
    it 'returns a temporary argument' do
      expect(processed.children[2]).to eq(constant_returner)
    end
  end

  describe 'rewriting a.b = c' do
    let(:input) do
      s(:send, receiver, :b=, single_argument)
    end

    it 'generates a temporary argument for a method argument' do
      expect(processed.children[0]).to eq(
        s(:lvasgn, "$writer", s(:array, single_argument))
      )
    end

    it 'calls receiver with this temporary argument as a splat' do
      expect(processed.children[1]).to eq(
        s(:send, receiver, :b=,
          s(:splat, s(:lvar, "$writer"))
        )
      )
    end

    include_examples 'always returns a temporary argument'
  end

  describe 'rewriting a.b = c, d' do
    let(:input) do
      s(:send, receiver, :b=, multiple_arguments)
    end

    it 'generates a temporary argument for array of method arguments' do
      expect(processed.children[0]).to eq(
        s(:lvasgn, "$writer", s(:array, multiple_arguments))
      )
    end

    it 'calls receiver with this temporary argument as a splat' do
      expect(processed.children[1]).to eq(
        s(:send, receiver, :b=,
          s(:splat, s(:lvar, "$writer"))
        )
      )
    end

    include_examples 'always returns a temporary argument'
  end

  describe "[]= method" do
    let(:idx) { s(:send, nil, :b) }

    describe 'rewriting a[b] = c' do
      let(:input) do
        s(:send, receiver, :[]=, idx, single_argument)
      end

      it 'generates a temporary argument for all passed method arguments' do
        expect(processed.children[0]).to eq(
          s(:lvasgn, "$writer", s(:array, idx, single_argument))
        )
      end

      it 'calls receiver with this temporary argument as a splat' do
        expect(processed.children[1]).to eq(
          s(:send, receiver, :[]=,
            s(:splat, s(:lvar, "$writer"))
          )
        )
      end

      include_examples 'always returns a temporary argument'
    end

    describe 'rewriting a[b] = c, d' do
      let(:input) do
        s(:send, receiver, :[]=, idx, multiple_arguments)
      end

      it 'generates a temporary argument for array of method arguments' do
        expect(processed.children[0]).to eq(
          s(:lvasgn, "$writer", s(:array, idx, multiple_arguments))
        )
      end

      it 'calls receiver with this temporary argument as a splat' do
        expect(processed.children[1]).to eq(
          s(:send, receiver, :[]=,
            s(:splat, s(:lvar, "$writer"))
          )
        )
      end

      include_examples 'always returns a temporary argument'
    end
  end

  describe 'mass assignment' do
    let(:input) do
      # a, b = c, d
      s(:masgn,
        s(:mlhs,
          s(:lvasgn, :a),
          s(:lvasgn, :b)),
        s(:array,
          s(:send, nil, :c),
          s(:send, nil, :d)))
    end

    it 'does not affect it' do
      expect_no_rewriting_for(input)
    end
  end

  describe '.JS. syntax' do
    let(:input) do
      # a.JS.b = c
      s(:jscall,
        s(:send, nil, :a), :b=,
        s(:send, nil, :c))
    end

    it 'does not affect it' do
      expect_no_rewriting_for(input)
    end
  end

  describe '.JS[] syntax' do
    let(:input) do
      s(:jsattrasgn,
        s(:send, nil, :a),
        s(:sym, :b),
        s(:send, nil, :c))
    end

    it 'does not affect it' do
      expect_no_rewriting_for(input)
    end
  end
end
