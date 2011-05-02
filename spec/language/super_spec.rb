require File.expand_path('../../spec_helper', __FILE__)
require File.expand_path('../fixtures/super', __FILE__)

describe "The super keyword" do

  it "calls the method on the calling class" do
    Super::S1::A.new.foo([]).should == ["A#foo", "A#bar"]
    Super::S1::A.new.bar([]).should == ["A#bar"]
    Super::S1::B.new.foo([]).should == ["B#foo","A#foo","B#bar","A#bar"]
    Super::S1::B.new.bar([]).should == ["B#bar", "A#bar"]
  end

  it "searches the full inheritence chain" do
    Super::S2::B.new.foo([]).should == ["B#foo", "A#baz"]
    Super::S2::B.new.baz([]).should == ["A#baz"]
    Super::S2::C.new.foo([]).should == ["B#foo","C#baz","A#baz"]
    Super::S2::C.new.baz([]).should == ["C#baz","A#baz"]
  end

  it "searches class methods" do
    Super::S3::A.new.foo([]).should == ["A#foo"]
    Super::S3::A.foo([]).should == ["A::foo"]
    Super::S3::A.bar([]).should == ["A::bar","A::foo"]
    Super::S3::B.new.foo([]).should == ["A#foo"]
    Super::S3::B.foo([]).should == ["B::foo","A::foo"]
    Super::S3::B.bar([]).should == ["B::bar","A::bar","B::foo","A::foo"]
  end

  it "calls the method on the calling class including modules" do
    Super::MS1::A.new.foo([]).should == ["ModA#foo", "ModA#bar"]
  end
end

