require 'native'

describe "Native" do
  it "can be used to extend Math" do
    class ExtendedMath < Native(`Math`)
      def self.toRadians(degrees)
        degrees * (self.PI / 180)
      end

      def initialize(precision)
        @Precision = precision
      end

      def sinDegrees(degrees)
        sin(self.class.toRadians(degrees)).round(@Precision)
      end
    end

    ExtendedMath.toRadians(90).should == `Math.PI / 2`
    ExtendedMath.new(2).sinDegrees(30).should == 0.50
  end

  it "works with #respond_to?" do
    class ExtendedMath2 < Native(`Math`)
      def self.sin2x(radians)
        self.sin(radians * 2)
      end

      def sin4x(radians)
        self.sin(radians * 4)
      end
    end

    ExtendedMath2.respond_to?(:sin).should be_true
    ExtendedMath2.respond_to?(:sin2x).should be_true

    ExtendedMath2.new.respond_to?(:cos).should be_true
    ExtendedMath2.new.respond_to?(:sin4x).should be_true
  end

  it "works with #send" do
    class ExtendedMath3 < Native(`Math`)
      def self.cos2x(radians)
        self.cos(radians * 2)
      end

      def cos4x(radians)
        self.cos(radians * 4)
      end
    end

    ExtendedMath3.send(:cos, 0).should == 1
    ExtendedMath3.new.send(:cos, Math::PI / 3).round(2).should == 0.50

    ExtendedMath3.send(:cos2x, 0).should == 1
    ExtendedMath3.new.send(:cos4x, Math::PI / 3).round(2).should == -0.50
  end

  it "works with #method" do
    class ExtendedMath4 < Native(`Math`)
      def self.tan2x(radians)
        self.tan(radians * 2)
      end

      def tan4x(radians)
        self.tan(radians * 4)
      end
    end
    ExtendedMath4.method(:tan).class.should == Method
    ExtendedMath4.method(:tan).call(Math::PI / 4).round(2).should == 1.00
    ExtendedMath4.method(:tan2x).call(Math::PI / 4).should == `Math.tan(Math.PI / 2)`

    ExtendedMath4.new.method(:tan).class.should == Method
    ExtendedMath4.new.method(:tan).call(Math::PI / 4).round(2).should == 1.00
    ExtendedMath4.new.method(:tan4x).call(Math::PI / 4).should == `Math.tan(Math.PI)`
  end

  it "doesn't fail when trying to extend null" do
    class ExtendNull < Native(`null`); end

    ExtendNull.nil?.should be_true
    ExtendNull.new.nil?.should be_true
    (ExtendNull == nil).should be_true
    (ExtendNull.new == nil).should be_true

    lambda { ExtendNull.new.missing }.should raise_error(NoMethodError)
  end

  it "doesn't fail when trying to extend undefined" do
    class ExtendUndefined < Native(`undefined`); end

    ExtendUndefined.nil?.should be_true
    ExtendUndefined.new.nil?.should be_true
    (ExtendUndefined == nil).should be_true
    (ExtendUndefined.new == nil).should be_true

    lambda { ExtendUndefined.new.missing }.should raise_error(NoMethodError)
  end

  it "is falsy when null or undefined" do
    class ExtendNull2 < Native(`null`); end
    class ExtendUndefined2 < Native(`undefined`); end

    [ExtendNull2, ExtendUndefined2, ExtendNull2.new, ExtendUndefined2.new].each do |target|
      (target ? true : false).should be_false
      (!target).should be_true
    end
  end
end

