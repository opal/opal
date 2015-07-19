describe "Method#to_proc" do

  it "returns a Proc object that is bound to the method's receiver" do
    "hello".method(:capitalize).to_proc.call.should == "Hello"
    "hello".method(:upcase).to_proc.call.should == "HELLO"
  end

  it "works with class methods" do
    class Lender
      def self.abc
        self
      end
      def self.xyz
        abc
      end
    end

    module Namespace
      class Borrower
        class << self
          define_method(:xyz, &::Lender.method(:xyz))
        end
      end
    end

    Namespace::Borrower.xyz.should == Lender
  end
end
