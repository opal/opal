describe "Native.new" do
  it "fails when trying to instantiate a non derived class" do
    lambda {
      Native.new
    }.should raise_error ArgumentError
  end

  it "should pass all arguments to derived classes" do
    Class.new(Native) {
      def initialize(a, b, &c)
        @a, @b, @c = a, b, c
      end

      def proper?
        not (@a.nil? || @b.nil? || @c.nil?)
      end
    }.new(1, 2) { }.proper?.should be_true
  end
end
