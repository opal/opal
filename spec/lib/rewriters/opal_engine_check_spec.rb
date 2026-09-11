require 'lib/spec_helper'
require 'support/rewriters_helper'

RSpec.describe Opal::Rewriters::OpalEngineCheck do
  include RewritersHelper

  let(:opal_str_sexp) { s(:str, 'opal') }
  let(:jruby_str_sexp) { s(:str, 'jruby') }
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

        context "when rhs == 'jruby'" do
          let(:check) do
            s(:send, ruby_const_sexp, :==, jruby_str_sexp)
          end

          it 'replaces the expression with the false branch' do
            expect_rewritten(
              s(:if, check, true_branch, false_branch)
            ).to eq(
              false_branch
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

        context "when rhs == 'jruby'" do
          let(:check) do
            s(:send, ruby_const_sexp, :!=, jruby_str_sexp)
          end

          it 'replaces the expression with the true branch' do
            expect_rewritten(
              s(:if, check, true_branch, false_branch)
            ).to eq(
              true_branch
            )
          end
        end
      end

      context 'when the dropped branch assigns local variables' do
        it 'declares them so they are still defined and nil' do
          expect_rewritten(
            # if RUBY_ENGINE != 'opal'
            #   a = 5
            # end
            s(:if,
              s(:send, ruby_const_sexp, :!=, opal_str_sexp),
              s(:lvasgn, :a, s(:int, 5))
            )
          ).to eq(
            s(:begin,
              s(:lvdeclare, :a),
              s(:nil)
            )
          )
        end

        it 'declares them when the else branch is dropped' do
          expect_rewritten(
            s(:if,
              s(:send, ruby_const_sexp, :==, opal_str_sexp),
              true_branch,
              s(:lvasgn, :b, s(:int, 2))
            )
          ).to eq(
            s(:begin,
              s(:lvdeclare, :b),
              true_branch
            )
          )
        end

        it 'ignores assignments inside a nested Ruby scope' do
          expect_rewritten(
            # if RUBY_ENGINE != 'opal'
            #   a = 5
            #   def foo; z = 9; end
            # end
            s(:if,
              s(:send, ruby_const_sexp, :!=, opal_str_sexp),
              s(:begin,
                s(:lvasgn, :a, s(:int, 5)),
                s(:def, :foo, s(:args), s(:lvasgn, :z, s(:int, 9)))
              )
            )
          ).to eq(
            s(:begin,
              s(:lvdeclare, :a),
              s(:nil)
            )
          )
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
