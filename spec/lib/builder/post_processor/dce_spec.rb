require 'lib/spec_helper'
require 'opal/builder'

RSpec.describe Opal::Builder::PostProcessor::DCE do
  let(:builder) { Opal::Builder.new(compiler_options: {cache_fragments: true}, dce: dce_types) }

  def build(code)
    builder.build_str(code, 'input.rb').to_s
  end

  context "when dce removes unused instance methods" do
    let(:dce_types) { [:method] }

    it "strips methods that are never referenced" do
      output = build(<<~'RUBY')
        class Foo
          def used; 1; end
          def unused; 2; end
        end

        Foo.new.used
      RUBY

      expect(output).to include("$def(self, '$used'")
      expect(output).not_to include("$def(self, '$unused'")
      expect(output).to include("Removed by DCE: unused")
    end
  end

  context "when constant DCE is enabled" do
    let(:dce_types) { [:const] }

    it "strips unused constant definitions" do
      output = build(<<~'RUBY')
        module M
          VALUE = 123
        end
      RUBY

      expect(output).to include("Removed by DCE: M")
      expect(output).not_to include("VALUE")
    end
  end

  context "when constant DCE is disabled" do
    let(:dce_types) { [:method] }

    it "keeps constants intact" do
      output = build(<<~'RUBY')
        module M
          VALUE = 123
        end
      RUBY

      expect(output).to include("VALUE")
      expect(output).not_to include("Removed by DCE")
    end
  end

  context "when using attr_* helpers" do
    let(:dce_types) { [:method] }

    it "removes generated readers/writers when unused" do
      output = build(<<~'RUBY')
        class Foo
          attr_accessor :bar
        end
      RUBY

      expect(output).to include("Removed by DCE: [:bar, :bar=]")
      expect(output).not_to include("$def(self, '$bar'")
    end
  end

  context "with alias_method" do
    let(:dce_types) { [:method] }

    it "keeps aliased methods when the alias is used" do
      output = build(<<~'RUBY')
        class Foo
          def bar; 1; end
          alias_method :baz, :bar
          baz
        end
      RUBY

      expect(output).to include("$def(self, '$bar'")
      expect(output).to include("alias_method")
      expect(output).not_to include("Removed by DCE: bar")
    end
  end
end
