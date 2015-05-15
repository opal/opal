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

  it "support :build option" do
    template = described_class.new('./spec/lib/fixtures/opal_file.rb', :build=>true)
    output = template.render
    expect(output).to include('"hi from opal!"')
    expect(output).to include('self.$require("corelib/runtime");')
  end

  it "support :builder option" do
    builder = Opal::Builder.new(:stubs=>['opal'])
    template = described_class.new('./spec/lib/fixtures/opal_file.rb', :builder=>builder)

    2.times do
      output = template.render
      expect(output.scan(/hi from opal!/).length).to eql(1)
      expect(output).not_to include('self.$require("corelib/runtime");')
    end
  end
end
