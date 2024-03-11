require 'lib/spec_helper'

RSpec.describe Opal::Project do
  context "when used by Builder" do
    let(:builder) do
      b = Opal::Builder.new
      b.append_paths(__dir__+"/fixtures/project")
      b
    end

    it "adds a project and adds a load path from Opalfile if a file is built" do
      b = builder
      b.build("p1/test")
      b.build("require_from_p3")
      b.to_s.should include("require_from_p3_working")
    end

    it "adds a project and adds a load path from Opalfile if a path is appended" do
      b = builder
      b.append_paths(__dir__+"/fixtures/project/p1")
      b.build("require_from_p3")
      b.to_s.should include("require_from_p3_working")
    end

    it "adds a project and adds a gem from Opalfile if a path is appended" do
      b = builder
      b.append_paths(__dir__+"/fixtures/project/p2")
      b.build("rake/version")
      b.to_s.should include("VERSION")
    end

    it "adds a project and adds an absolute load path from Opalfile if a path is appended" do
      b = builder
      b.append_paths(__dir__+"/fixtures/project/p5")
      b.build("require_from_p3")
      b.to_s.should include("require_from_p3_working")
    end

    it "raises when Opalfile contains an unknown directive" do
      b = builder
      -> do
        b.append_paths(__dir__+"/fixtures/project/p4")
      end.should raise_error Opal::OpalfileUnknownDirective
    end

    it "doesn't break when adding a non-existent load path" do
      b = builder
      -> do
        b.append_paths(__dir__+"/fixtures/project/non_existent")
      end.should_not raise_error
    end

    context "should include gem paths by default" do
      %w[racc/info parser/version ast].each do |gem|
        it "for #{gem.split('/').first}" do
          b = builder
          b.build("#{gem}")
          b.to_s.should include(gem == 'ast' ? "AST" : "VERSION")
        end
      end
    end
  end
end
