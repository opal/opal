require 'spec_helper'

describe Opal::Rails::Processor do

  it "is registered for '.opal' files" do
    Tilt['test.opal'].should eq(Opal::Rails::Processor)
  end

  it "is registered for '.rb' files" do
    Tilt['test.rb'].should eq(Opal::Rails::Processor)
  end

  it "compiles and evaluates the template on #render" do
    template = Opal::Rails::Processor.new { |t| "puts 'Hello, World!'\n" }
    template.render.should include('self.$puts("Hello, World!")')
  end

  it "can be rendered more than once" do
    template = Opal::Rails::Processor.new { |t| "puts 'Hello, World!'\n" }
    3.times { template.render.should include('self.$puts("Hello, World!")') }
  end
end
