module AppendFeaturesSpec
  class Klass; end

  def self.append_features(mod)
    ScratchPad.record mod
  end
end

describe "Module#append_features" do
  it "gets called when self is included in another module/class" do
    AppendFeaturesSpec::Klass.include AppendFeaturesSpec
    ScratchPad.recorded.should == AppendFeaturesSpec::Klass
  end
end