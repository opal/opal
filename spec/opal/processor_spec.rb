require 'spec_helper'

describe Opal::Processor do

  it "is registered for '.opal' files" do
    Tilt['test.opal'].should eq(Opal::Processor)
  end

  it "is registered for '.rb' files" do
    Tilt['test.rb'].should eq(Opal::Processor)
  end

  it "compiles and evaluates the template on #render" do
    template = Opal::Processor.new { |t| "puts 'Hello, World!'\n" }
    template.render.should include('self.$puts("Hello, World!")')
  end

  it "can be rendered more than once" do
    template = Opal::Processor.new { |t| "puts 'Hello, World!'\n" }
    3.times { template.render.should include('self.$puts("Hello, World!")') }
  end
end
