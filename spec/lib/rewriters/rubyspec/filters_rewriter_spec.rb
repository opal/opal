require 'lib/spec_helper'
require 'opal/rewriters/rubyspec/filters_rewriter'
require 'support/rewriters_helper'

RSpec.describe Opal::Rubyspec::FiltersRewriter do
  include RewritersHelper

  let(:source) do
    <<-SOURCE
      describe 'User#email' do
        context 'when this' do
          it 'does that'

          it 'and does that' do
            42
          end
        end

        it 'also does something else'
      end
    SOURCE
  end

  let(:ast) { parse(source) }

  context 'when spec is filtered' do
    around(:each) do |e|
      Opal::Rubyspec::FiltersRewriter.filter 'User#email when this does that'
      Opal::Rubyspec::FiltersRewriter.filter 'User#email when this and does that'
      e.run
      Opal::Rubyspec::FiltersRewriter.clear_filters!
    end

    let(:rewritten_source) do
      <<-SOURCE
        describe 'User#email' do
          context 'when this' do
            nil # <- right here
            nil # <- and here
          end

          it 'also does something else'
        end
      SOURCE
    end

    let(:expected_ast) { parse(rewritten_source) }

    it 'replaces it with nil' do
      expect_rewritten(ast).to eq(expected_ast)
    end

    it 'disables cache' do
      expect(rewritten(ast).meta[:dynamic_cache_result]).to be_truthy
    end
  end

  context 'when spec is not filtered' do
    it 'does not rewrite it' do
      expect_no_rewriting_for(ast)
    end

    it 'disables cache' do
      expect(rewritten(ast).meta[:dynamic_cache_result]).to be_truthy
    end
  end
end
