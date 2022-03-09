require 'lib/spec_helper'
require 'support/rewriters_helper'

RSpec.describe Opal::Rewriters::DotJsSyntax do
  include RewritersHelper

  context '.JS. syntax' do
    let(:send_node) do
      # a.JS.b(1)
      s(:send,
        s(:send, s(:lvar, :a), :JS),
        :b,
        s(:int, 1)
      )
    end

    let(:dot_js_node) do
      s(:jscall, s(:lvar, :a), :b, s(:int, 1))
    end

    it 'rewrites s(:send, s(:send, obj, :JS), :js_method, ...) to s(:jscall, obj, :js_method, ...)' do
      expect(rewriter.process(send_node)).to eq(dot_js_node)
    end
  end

  context '.JS[] syntax' do
    context 'when passed one argument' do
      let(:send_node) do
        # a.JS[1, 2]
        s(:send,
          s(:send, s(:lvar, :a), :JS),
          :[],
          s(:int, 1)
        )
      end

      let(:jsattr_node) do
        s(:jsattr, s(:lvar, :a), s(:int, 1))
      end

      it 'rewrites s(:send, s(:send, obj, :JS), :[], arg) to s(:jsattr, obj, arg)' do
        expect(rewriter.process(send_node)).to eq(jsattr_node)
      end
    end

    context 'when passed 1+ arguments' do
      let(:send_node) do
        # a.JS[1, 2]
        s(:send,
          s(:send, s(:lvar, :a), :JS),
          :[],
          s(:int, 1),
          s(:int, 2)
        )
      end

      it 'raises syntax error' do
        expect {
          rewriter.process(send_node)
        }.to raise_error(Opal::RewritingError)
      end
    end
  end

  context '.JS[]= syntax' do
    context 'when passed two arguments' do
      let(:send_node) do
        # a.JS[1] = 2
        s(:send,
          s(:send, s(:lvar, :a), :JS),
          :[]=,
          s(:int, 1),
          s(:int, 2)
        )
      end

      let(:jsattr_asgn_node) do
        s(:jsattrasgn, s(:lvar, :a), s(:int, 1), s(:int, 2))
      end

      it 'converts send node to jsattrasgn' do
        expect(rewriter.process(send_node)).to eq(jsattr_asgn_node)
      end
    end

    context 'when passed 2+ arguments' do
      let(:send_node) do
        # a.JS[1, 2] = 3
        s(:send,
          s(:send, s(:lvar, :a), :JS),
          :[]=,
          s(:int, 1),
          s(:int, 2),
          s(:int, 3)
        )
      end

      it 'raises syntax error' do
        expect {
          rewriter.process(send_node)
        }.to raise_error(Opal::RewritingError)
      end
    end
  end
end
