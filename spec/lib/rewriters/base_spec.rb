require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/base'

RSpec.describe Opal::Rewriters::Base do
  include RewritersHelper

  def body_ast_of(method_source)
    def_ast = ast_of(method_source)
    _, _, body_ast = *def_ast
    body_ast
  end

  let(:node) { ast_of('INJECTED') } # s(:const, nil, :INJECTED)
  let(:rewriter) { described_class.new }

  describe '#prepend_to_body' do
    context 'for empty body' do
      it 'replaces body with provided node' do
        body = body_ast_of('def m(a); end')
        rewritten = rewriter.prepend_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; INJECTED; end'))
      end
    end

    context 'for single-line body' do
      it 'prepends a node to the body and wraps it with begin; end' do
        body = body_ast_of('def m; 1; end')
        rewritten = rewriter.prepend_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; INJECTED; 1; end'))
      end
    end

    context 'for multi-line body' do
      it 'prepends a node to the body' do
        body = body_ast_of('def m(a); 1; 2; end')
        rewritten = rewriter.prepend_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; INJECTED; 1; 2; end'))
      end
    end
  end

  describe '#append_to_body' do
    context 'for empty body' do
      it 'replaces body with provided node' do
        body = body_ast_of('def m(a); end')
        rewritten = rewriter.append_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; INJECTED; end'))
      end
    end

    context 'for single-line body' do
      it 'appends a node to the body and wraps it with begin; end' do
        body = body_ast_of('def m(a); 1; end')
        rewritten = rewriter.append_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; 1; INJECTED; end'))
      end
    end

    context 'for multi-line body' do
      it 'appends a node to the body' do
        body = body_ast_of('def m(a); 1; 2; end')
        rewritten = rewriter.append_to_body(body, node)
        expect(rewritten).to eq(body_ast_of('def m; 1; 2; INJECTED; end'))
      end
    end
  end
end
