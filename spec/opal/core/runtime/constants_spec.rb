module RuntimeFixtures
  class A
  end

  class A::B
    module C
    end
  end

  module ModuleB
  end

  module ModuleA
    include ModuleB
  end
end

describe "Constants access via .$$ with dots (regression for #1418)" do
  it "allows to acces scopes on `Opal`" do
    `Opal.Object.$$.RuntimeFixtures.$$.A.$$.B.$$.C`.should == RuntimeFixtures::A::B::C
  end
end

describe "Inclusion of modules" do
  it "that have been included by other modules works" do
    # here ClassC would have failed to be build due to a bug in Opal.append_features
    module RuntimeFixtures
      class ClassC
        include ModuleA
        include ModuleB
      end
    end
    RuntimeFixtures::ClassC.new.class.should == RuntimeFixtures::ClassC
  end
end
