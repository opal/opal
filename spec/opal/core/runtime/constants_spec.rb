module RuntimeFixtures
  class A
  end

  class A::B
    module C

    end
  end
end

describe "Constants access via .$$ with dots (regression for #1418)" do
  it "allows to acces scopes on `Opal`" do
    `Opal.Object.$$.RuntimeFixtures.$$.A.$$.B.$$.C`.should == RuntimeFixtures::A::B::C
  end
end
