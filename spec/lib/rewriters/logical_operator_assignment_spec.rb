require 'lib/spec_helper'
require 'support/rewriters_helper'

RSpec.describe Opal::Rewriters::LogicalOperatorAssignment do
  include RewritersHelper

  use_only_described_rewriter!

  before(:each) { Opal::Rewriters::LogicalOperatorAssignment.reset_tmp_counter! }
  let(:cache_tmp_name) { :$logical_op_recvr_tmp_1 }
  let(:cached) { s(:js_tmp, cache_tmp_name) }

  context 'rewriting or_asgn and and_asgn nodes' do
    context 'local variable' do
      include_examples 'it rewrites source-to-source', 'a = local; a ||= 1', 'a = local; a = a || 1'
      include_examples 'it rewrites source-to-source', 'a = local; a &&= 1', 'a = local; a = a && 1'
    end

    context 'instance variable' do
      include_examples 'it rewrites source-to-source', '@a ||= 1', '@a = @a || 1'
      include_examples 'it rewrites source-to-source', '@a &&= 1', '@a = @a && 1'
    end

    context 'constant' do
      include_examples 'it rewrites source-to-source', 'CONST ||= 1', 'CONST = defined?(CONST) ? (CONST || 1) : 1'
      include_examples 'it rewrites source-to-source', 'CONST &&= 1', 'CONST = CONST && 1'
    end

    context 'global variable' do
      include_examples 'it rewrites source-to-source', '$g ||= 1', '$g = $g || 1'
      include_examples 'it rewrites source-to-source', '$g &&= 1', '$g = $g && 1'
    end

    context 'class variable' do
      include_examples 'it rewrites source-to-source', '@@a ||= 1', '@@a = defined?(@@a) ? (@@a || 1) : 1'
      include_examples 'it rewrites source-to-source', '@@a &&= 1', '@@a = @@a && 1'
    end

    context 'simple method call' do
      include_examples 'it rewrites source-to-source', 'recvr = 1; recvr.meth ||= rhs', 'recvr = 1; recvr.meth || recvr.meth = rhs'
      include_examples 'it rewrites source-to-source', 'recvr = 1; recvr.meth &&= rhs', 'recvr = 1; recvr.meth && recvr.meth = rhs'
    end

    context '[] / []= method call' do
      include_examples 'it rewrites source-to-source', 'recvr = 1; recvr[idx] ||= rhs', 'recvr = 1; recvr[idx] || recvr[idx] = rhs'
      include_examples 'it rewrites source-to-source', 'recvr = 1; recvr[idx] &&= rhs', 'recvr = 1; recvr[idx] && recvr[idx] = rhs'
    end

    context '[] / []= method call with multiple arguments' do
      include_examples 'it rewrites source-to-source',
        'recvr = 1; recvr[idx1, idx2] ||= rhs',
          'recvr = 1; recvr[idx1, idx2] || recvr[idx1, idx2] = rhs'

      include_examples 'it rewrites source-to-source',
        'recvr = 1; recvr[idx1, idx2] &&= rhs',
          'recvr = 1; recvr[idx1, idx2] && recvr[idx1, idx2] = rhs'
    end

    context 'chain of method calls' do
      it 'rewrites ||= by caching receiver to a temporary local variable' do
        input = parse('recvr.a.b ||= rhs')
        rewritten = rewrite(input).children.first

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, ast_of('recvr.a')), # cached = recvr.a
          s(:or,
            s(:send, cached, :b),                        # cached.b ||
            s(:send, cached, :b=, ast_of('rhs'))))       # cached.b = rhs

        expect(rewritten).to eq(expected)
      end

      it 'rewrites &&= by caching receiver to a temporary local variable' do
        input = parse('recvr.a.b &&= rhs')
        rewritten = rewrite(input).children.first

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, ast_of('recvr.a')), # cached = recvr.a
          s(:and,
            s(:send, cached, :b),                        # cached.b ||
            s(:send, cached, :b=, ast_of('rhs'))))       # cached.b = rhs

        expect(rewritten).to eq(expected)
      end
    end

    context 'method call using safe nafigator' do
      it 'rewrites ||= by caching receiver and rewriting it to if and or_asgn' do
        input = parse('recvr&.meth ||= rhs')
        rewritten = rewrite(input).children.first

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, ast_of('recvr')), # cached = recvr
          s(:if, s(:send, cached, :nil?),              # if cached.nil?
            s(:nil),                                   #   nil
                                                       # else
            s(:or,
              s(:send, cached, :meth),                 #   cached.meth ||
              s(:send, cached, :meth=, ast_of('rhs'))) #     cached.meth = rhs
            )                                          # end
          )

        expect(rewritten).to eq(expected)
      end

      it 'rewrites &&= by caching receiver and rewriting it to if and or_asgn' do
        input = parse('recvr&.meth &&= rhs')
        rewritten = rewrite(input).children.first

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, ast_of('recvr')), # cached = recvr
          s(:if, s(:send, cached, :nil?),              # if cached.nil?
            s(:nil),                                   #   nil
                                                       # else
            s(:and,
              s(:send, cached, :meth),                 #   cached.meth &&
              s(:send, cached, :meth=, ast_of('rhs'))) #     cached.meth = rhs
            )                                          # end
          )

        expect(rewritten).to eq(expected)
      end
    end
  end

  context 'rewriting defined?(or_asgn) and defined?(and_asgn)' do
    context 'local variable' do
      include_examples 'it rewrites source-to-source', 'a = nil; defined?(a ||= 1)', 'a = nil; "assignment"'
      include_examples 'it rewrites source-to-source', 'a = nil; defined?(a &&= 1)', 'a = nil; "assignment"'
    end

    context 'instance variable' do
      include_examples 'it rewrites source-to-source', 'defined?(@a ||= 1)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(@a &&= 1)', %q("assignment")
    end

    context 'constant' do
      include_examples 'it rewrites source-to-source', 'defined?(CONST ||= 1)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(CONST &&= 1)', %q("assignment")
    end

    context 'global variable' do
      include_examples 'it rewrites source-to-source', 'defined?($g ||= 1)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?($g &&= 1)', %q("assignment")
    end

    context 'class variable' do
      include_examples 'it rewrites source-to-source', 'defined?(@@a ||= 1)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(@@a &&= 1)', %q("assignment")
    end

    context 'simple method call' do
      include_examples 'it rewrites source-to-source', 'defined?(recvr.meth ||= rhs)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(recvr.meth &&= rhs)', %q("assignment")
    end

    context '[] / []= method call' do
      include_examples 'it rewrites source-to-source', 'defined?(recvr[idx] ||= rhs)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(recvr[idx] &&= rhs)', %q("assignment")
    end

    context '[] / []= method call with multiple arguments' do
      include_examples 'it rewrites source-to-source', 'defined?(recvr[idx1, idx2] ||= rhs)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(recvr[idx1, idx2] &&= rhs)', %q("assignment")
    end

    context 'chain of method calls' do
      include_examples 'it rewrites source-to-source', 'defined?(recvr.a.b.c ||= rhs)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(recvr.a.b.c &&= rhs)', %q("assignment")
    end

    context 'method call using safe nafigator' do
      include_examples 'it rewrites source-to-source', 'defined?(recvr&.meth ||= rhs)', %q("assignment")
      include_examples 'it rewrites source-to-source', 'defined?(recvr&.meth &&= rhs)', %q("assignment")
    end
  end
end
