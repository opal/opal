require 'lib/spec_helper'
require 'support/rewriters_helper'
require 'opal/rewriters/hashes/key_duplicates_rewriter'

RSpec.describe Opal::Rewriters::Hashes::KeyDuplicatesRewriter do
  include RewritersHelper

  shared_examples 'it warns' do |code, key_to_warn|
    context "for #{code} code" do
      it "warns about #{key_to_warn.inspect} being overwritten" do
        expect(Kernel).to receive(:warn).with("warning: key #{key_to_warn.inspect} is duplicated and overwritten")

        ast = parse_without_rewriting(code)
        rewrite(ast)
      end
    end
  end

  include_examples 'it warns', '{ a: 1, a: 2 }',             :a
  include_examples 'it warns', '{ a: 1, **{ a: 2 } }',       :a
  include_examples 'it warns', '{ a: 1, **{ **{ a: 2 } } }', :a

  include_examples 'it warns', '{ "a" => 1, "a" => 2 }',             'a'
  include_examples 'it warns', '{ "a" => 1, **{ "a" => 2 } }',       'a'
  include_examples 'it warns', '{ "a" => 1, **{ **{ "a" => 2 } } }', 'a'

  shared_examples 'it does not warn' do |code|
    context "for #{code} code" do
      it "does not warn anything" do
        expect(Kernel).to_not receive(:warn).with(/is duplicated and overwritten/)

        ast = parse_without_rewriting(code)
        rewrite(ast)
      end
    end
  end

  include_examples 'it does not warn', '{ a: 1 }'
  include_examples 'it does not warn', '{ a: 1, "a" => 2 }'
  include_examples 'it does not warn', '{ "a" => 1, a: 2 }'
  include_examples 'it does not warn', '{ a: 1, **{ "a" => 2 } }'
  include_examples 'it does not warn', '{ "a" => 1, **{ a: 2 } }'
  include_examples 'it does not warn', '{ a: 1, nested: { a: 2 } }'

  include_examples 'it does not warn', 'key = "key"; { "#{key}" => 1, "#{key}" => 2 }'
  include_examples 'it does not warn', 'key = "key"; { :"#{key}" => 1, :"#{key}" => 2 }'
end
