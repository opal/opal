require 'lib/spec_helper'

describe Opal::Rewriters::JsReservedWords do
  def s(type, *children)
    ::Opal::AST::Node.new(type, children)
  end

  def expect_rewritten(sexp)
    processed = Opal::Rewriters::JsReservedWords.new.process(sexp)
    expect(processed)
  end

  def expect_no_rewriting_for(sexp)
    expect_rewritten(sexp).to eq(sexp)
  end

  reserved_lvars = %i(
    do if in for let new try var case else enum eval false
    null this true void with break catch class const super
    throw while yield delete export import public return
    static switch typeof default extends finally package
    private continue debugger function arguments interface
    protected implements instanceof

    int byte char goto long final float short double native
    throws boolean abstract volatile transient synchronized

    NaN Infinity undefined
  )

  reserved_ivars = %i(
    @constructor @displayName
    @hasOwnProperty @valueOf
    @__proto__ @__parent__
    @__noSuchMethod__ @__count__
  )

  context 'reserved lvars' do
    reserved_lvars.each do |lvar_name|
      context 'as lvars' do
        it "appends '$'" do
          expect_rewritten(
            s(:lvar, lvar_name)
          ).to eq(
            s(:lvar, :"#{lvar_name}$")
          )

          expect_rewritten(
            s(:lvasgn, lvar_name, s(:int, 1))
          ).to eq(
            s(:lvasgn, :"#{lvar_name}$", s(:int, 1))
          )
        end
      end

      context 'as arguments' do
        it "appends '$'" do
          [:arg, :restarg, :blockarg, :shadowarg, :kwarg, :kwrestarg].each do |type|
            expect_rewritten(
              s(type, lvar_name)
            ).to eq(
              s(type, :"#{lvar_name}$")
            )
          end

          [:optarg, :kwoptarg].each do |type|
            expect_rewritten(
              s(type, lvar_name, s(:nil))
            ).to eq(
              s(type, :"#{lvar_name}$", s(:nil))
            )
          end
        end
      end
    end
  end

  context 'reserved ivars' do
    reserved_ivars.each do |ivar_name|
      it "appends '$' to :ivar #{ivar_name}" do
        expect_rewritten(
          s(:ivar, ivar_name)
        ).to eq(
          s(:ivar, :"#{ivar_name}$")
        )
      end

      it "appends '$' to :ivasgn #{ivar_name}" do
        expect_rewritten(
          s(:ivasgn, ivar_name, s(:nil))
        ).to eq(
          s(:ivasgn, :"#{ivar_name}$", s(:nil))
        )
      end
    end
  end

  context 'normal lvar name' do
    it 'does not modify AST' do
      expect_no_rewriting_for(s(:lvar, :a))
      expect_no_rewriting_for(s(:lvasgn, :a))
    end
  end

  context 'normal ivar name' do
    it 'does not modify AST' do
      [:arg, :restarg, :blockarg, :shadowarg, :kwarg, :kwrestarg].each do |type|
        expect_no_rewriting_for(s(type, :a))
      end

      [:optarg, :kwoptarg].each do |type|
        expect_no_rewriting_for(s(type, :a, s(:nil)))
      end
    end
  end
end
