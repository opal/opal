require 'lib/spec_helper'
require 'opal/sprockets/processor'

describe Opal::Processor do
  let(:pathname) { Pathname("/Code/app/mylib/opal/foo.#{ext}") }
  let(:environment) { double('environment',
    cache: nil,
    :[] => nil,
    resolve: pathname.expand_path.to_s,
  ) }
  let(:sprockets_context) { double('context',
    logical_path: "foo.#{ext}",
    environment: environment,
    pathname: pathname,
    is_a?: true,
  ) }

  %w[rb js.rb opal js.opal].each do |ext|
    let(:ext) { ext }

    describe %Q{with extension ".#{ext}"} do
      it "is registered for '.#{ext}' files" do
        expect(Tilt["test.#{ext}"]).to eq(described_class)
      end

      it "compiles and evaluates the template on #render" do
        template = described_class.new { |t| "puts 'Hello, World!'\n" }
        expect(template.render(sprockets_context)).to include('"Hello, World!"')
      end
    end
  end

end
