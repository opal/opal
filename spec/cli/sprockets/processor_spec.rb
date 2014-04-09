require 'cli/spec_helper'
require 'opal/sprockets/processor'

describe Opal::Processor do
  let(:pathname) { Pathname("/Code/app/mylib/opal/foo.#{ext}") }
  let(:_context) { double('_context', :logical_path => "foo.#{ext}", :pathname => pathname, :resolve => pathname.expand_path) }

  %w[rb js.rb opal js.opal].each do |ext|
    let(:ext) { ext }

    describe %Q{with extension ".#{ext}"} do
      it "is registered for '.#{ext}' files" do
        expect(Tilt["test.#{ext}"]).to eq(described_class)
      end

      it "compiles and evaluates the template on #render" do
        template = described_class.new { |t| "puts 'Hello, World!'\n" }
        expect(template.render(_context)).to include('"Hello, World!"')
      end

      it "can be rendered more than once" do
        template = described_class.new(_context) { |t| "puts 'Hello, World!'\n" }
        3.times { expect(template.render(_context)).to include('"Hello, World!"') }
      end
    end
  end

end
