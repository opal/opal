require 'lib/spec_helper'

RSpec.describe Opal::Rewriters::BinaryOperatorAssignment do
  def s(type, *children)
    ::Opal::AST::Node.new(type, children)
  end

  let(:rewriter) { Opal::Rewriters::BinaryOperatorAssignment.new }

  def parse(source)
    parser = Opal::Parser.default_parser
    buffer = ::Opal::Parser::SourceBuffer.new('(eval)')
    buffer.source = source
    parser.parse(buffer)
  end

  def rewrite(ast)
    rewriter.process(ast)
  end

  around(:each) do |e|
    Opal::Rewriters::BinaryOperatorAssignment.reset_tmp_counter!
    Opal::Rewriter.disable { e.run }
  end
  let(:cache_tmp_name) { :$binary_op_recvr_tmp_1 }
  let(:cached) { s(:js_tmp, cache_tmp_name) }

  shared_examples 'it rewrites' do |from, to|
    it "rewrites #{from.inspect} to #{to.inspect}" do
      input = parse(from)
      rewritten = rewrite(input)
      expected = parse(to)

      expect(rewritten).to eq(expected)
    end
  end

  context 'rewriting or_asgn and and_asgn nodes' do
    context 'local variable' do
      include_examples 'it rewrites', 'a = 1; a += 2', 'a = 1; a = a + 2'
    end

    context 'instance variable' do
      include_examples 'it rewrites', '@a += 1', '@a = @a + 1'
    end

    context 'constant' do
      include_examples 'it rewrites', 'CONST += 1', 'CONST = CONST + 1'
    end

    context 'global variable' do
      include_examples 'it rewrites', '$g += 1', '$g = $g + 1'
    end

    context 'class variable' do
      include_examples 'it rewrites', '@@a += 1', '@@a = @@a + 1'
    end

    context 'simple method call' do
      include_examples 'it rewrites', 'recvr = 1; recvr.meth += rhs', 'recvr = 1; recvr.meth = recvr.meth + rhs'
    end

    context '[] / []= method call' do
      include_examples 'it rewrites', 'recvr = 1; recvr[idx] += rhs', 'recvr = 1; recvr[idx] = recvr[idx] + rhs'
    end

    context '[] / []= method call with multiple arguments' do
      include_examples 'it rewrites',
        'recvr = 1; recvr[idx1, idx2] += rhs',
          'recvr = 1; recvr[idx1, idx2] = recvr[idx1, idx2] + rhs'
    end

    context 'chain of method calls' do
      it 'rewrites += by caching receiver to a temporary local variable' do
        input = parse('recvr.a.b += rhs')
        rewritten = rewrite(input)

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, parse('recvr.a')), # cached = recvr.a
          s(:send, cached, :b=,
            s(:send,
              s(:send, cached, :b),
              :+,
              parse('rhs'))))

        expect(rewritten).to eq(expected)
      end
    end

    context 'method call using safe nafigator' do
      it 'rewrites += by caching receiver and rewriting it to if and or_asgn' do
        input = parse('recvr&.meth += rhs')
        rewritten = rewrite(input)

        expected = s(:begin,
          s(:lvasgn, cache_tmp_name, parse('recvr')), # cached = recvr
          s(:if, s(:send, cached, :nil?),             # if cached.nil?
            s(:nil),                                  #   nil
                                                      # else
            s(:send, cached, :meth=,                  #   cached.meth =
              s(:send,
                s(:send, cached, :meth),              #     cached.meth +
                :+,
                parse('rhs')))                        #     rhs
          ))                                          # end

        expect(rewritten).to eq(expected)
      end
    end
  end

  context 'rewriting defined?(or_asgn) and defined?(and_asgn)' do
    context 'local variable' do
      include_examples 'it rewrites', 'a = nil; defined?(a += 1)', 'a = nil; "assignment"'
    end

    context 'instance variable' do
      include_examples 'it rewrites', 'defined?(@a += 1)', %q("assignment")
    end

    context 'constant' do
      include_examples 'it rewrites', 'defined?(CONST += 1)', %q("assignment")
    end

    context 'global variable' do
      include_examples 'it rewrites', 'defined?($g += 1)', %q("assignment")
    end

    context 'class variable' do
      include_examples 'it rewrites', 'defined?(@@a += 1)', %q("assignment")
    end

    context 'simple method call' do
      include_examples 'it rewrites', 'defined?(recvr.meth += rhs)', %q("assignment")
    end

    context '[] / []= method call' do
      include_examples 'it rewrites', 'defined?(recvr[idx] += rhs)', %q("assignment")
    end

    context '[] / []= method call with multiple arguments' do
      include_examples 'it rewrites', 'defined?(recvr[idx1, idx2] += rhs)', %q("assignment")
    end

    context 'chain of method calls' do
      include_examples 'it rewrites', 'defined?(recvr.a.b.c += rhs)', %q("assignment")
    end

    context 'method call using safe nafigator' do
      include_examples 'it rewrites', 'defined?(recvr&.meth += rhs)', %q("assignment")
    end
  end
end
