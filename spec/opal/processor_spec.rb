require 'spec_helper'

describe Opal::Processor do
  # Preparing a context that responds to #logical_path and #require_asset
  # should't be necessary:
  let(:_context) { double('_context', :logical_path => 'asdf.js.rb' ) }

  it "is registered for '.opal' files" do
    Tilt['test.opal'].should eq(Opal::Processor)
  end

  it "is registered for '.rb' files" do
    Tilt['test.rb'].should eq(Opal::Processor)
  end

  it "compiles and evaluates the template on #render" do
    template = Opal::Processor.new { |t| "puts 'Hello, World!'\n" }
    template.render(_context).should include('"Hello, World!"')
  end

  it "can be rendered more than once" do
    template = Opal::Processor.new(_context) { |t| "puts 'Hello, World!'\n" }
    3.times { template.render(_context).should include('"Hello, World!"') }
  end
end
