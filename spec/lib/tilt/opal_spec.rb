require 'lib/spec_helper'
require 'tilt/opal'

describe Opal::TiltTemplate do
  %w[rb js.rb opal js.opal].each do |ext|
    let(:ext) { ext }

    describe %Q{with extension ".#{ext}"} do
      it "is registered for '.#{ext}' files" do
        expect(Tilt["test.#{ext}"]).to be <= described_class
      end

      it "compiles and evaluates the template on #render" do
        template = described_class.new('file') { |t| "puts 'Hello, World!'\n" }
        expect(template.render(Object.new)).to include('"Hello, World!"')
      end
    end
  end
end
