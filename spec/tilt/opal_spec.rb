require 'spec_helper'
require 'tilt/opal'

describe Tilt::OpalTemplate do
  
  it "is registered for '.opal' files" do
    Tilt['test.opal'].should eq(Tilt::OpalTemplate)
  end

  it "compiles and evaluates the template on #render" do
    template = Tilt::OpalTemplate.new { |t| "puts 'Hello, World!'\n" }
    template.render.should include(".m$puts('Hello, World!');")
  end

  it "can be rendered more than once" do
    template = Tilt::OpalTemplate.new { |t| "puts 'Hello, World!'\n" }
    3.times { template.render.should include(".m$puts('Hello, World!');") }
  end
end
