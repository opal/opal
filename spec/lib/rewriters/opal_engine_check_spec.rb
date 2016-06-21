require 'lib/spec_helper'

describe Opal::Rewriters::OpalEngineCheck do
  def s(type, *children)
    ::Parser::AST::Node.new(type, children)
  end

  let(:rewriter) { Opal::Rewriters::OpalEngineCheck.new }

  def expect_rewritten(node)
    processed = rewriter.process(node)
    expect(processed)
  end

  def expect_no_rewriting_for(node)
    expect_rewritten(node).to eq(node)
  end

  let(:opal_str_sexp) { s(:str, 'opal') }
  let(:true_branch) { s(:int, 1) }
  let(:false_branch) { s(:int, 2) }

  [:RUBY_ENGINE, :RUBY_PLATFORM].each do |const_name|
    let(:ruby_const_sexp) { s(:const, nil, const_name) }

    context "#{const_name} == rhs" do
      context "when rhs == 'opal'" do
        let(:check) do
          s(:send, ruby_const_sexp, :==, opal_str_sexp)
        end

        it 'replaces true branch with s(:nil)' do
          expect_rewritten(
            s(:if, check, true_branch, false_branch)
          ).to eq(
            s(:if, check, true_branch, s(:nil))
          )
        end
      end

      context "when rhs != 'opal'" do
        let(:check) do
          s(:send, ruby_const_sexp, :==, s(:nil))
        end

        it 'does not modify sexp' do
          expect_no_rewriting_for(
            s(:if, check, true_branch, false_branch)
          )
        end
      end
    end

    context "#{const_name} != rhs" do
      context "when rhs == 'opal'" do
        let(:check) do
          s(:send, ruby_const_sexp, :!=, opal_str_sexp)
        end

        it 'replaces true branch with s(:nil)' do
          expect_rewritten(
            s(:if, check, true_branch, false_branch)
          ).to eq(
            s(:if, check, s(:nil), false_branch)
          )
        end
      end

      context "when rhs != 'opal'" do
        let(:check) do
          s(:send, ruby_const_sexp, :!=, s(:nil))
        end

        it 'does not modify sexp' do
          expect_no_rewriting_for(
            s(:if, check, true_branch, false_branch)
          )
        end
      end
    end
  end
end
