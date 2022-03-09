require 'lib/spec_helper'
require 'support/rewriters_helper'

RSpec.describe Opal::Rewriters::OpalEngineCheck do
  include RewritersHelper

  let(:opal_str_sexp) { s(:str, 'opal') }
  let(:true_branch) { s(:int, 1) }
  let(:false_branch) { s(:int, 2) }

  [:RUBY_ENGINE, :RUBY_PLATFORM].each do |const_name|
    context "for #{const_name} constant" do
      let(:ruby_const_sexp) { s(:const, nil, const_name) }

      context "#{const_name} == rhs" do
        context "when rhs == 'opal'" do
          let(:check) do
            s(:send, ruby_const_sexp, :==, opal_str_sexp)
          end

          it 'replaces the expression with the true branch' do
            expect_rewritten(
              s(:if, check, true_branch, false_branch)
            ).to eq(
              true_branch
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

          it 'replaces the expression with the false branch' do
            expect_rewritten(
              s(:if, check, true_branch, false_branch)
            ).to eq(
              false_branch
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

      it 'supports nested blocks' do
        expect_rewritten(
          # if true
          #   if RUBY_ENGINE == 'opal'
          #     if RUBY_ENGINE == 'opal'
          #       :a
          #     end
          #     if RUBY_ENGINE != 'opal'
          #       :b
          #     end
          #   end
          # end

          s(:if,
            s(:true),
            s(:if,
              s(:send, ruby_const_sexp, :==, opal_str_sexp),
              s(:begin,
                s(:if,
                  s(:send, ruby_const_sexp, :==, opal_str_sexp),
                  s(:sym, :a)
                ),
                s(:if,
                  s(:send, ruby_const_sexp, :!=, opal_str_sexp),
                  s(:sym, :b)
                )
              )
            )
          )
        ).to eq(
          # if true
          #   :a
          #   nil
          # end

          s(:if,
            s(:true),
            s(:begin,
              s(:sym, :a),
              s(:nil)
            )
          )
        )
      end
    end
  end
end
