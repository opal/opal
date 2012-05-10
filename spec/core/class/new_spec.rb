describe "Class.new with a block given" do
  it "uses the given block as the class' body" do
    klass = Class.new do
      def self.message
        "text"
      end

      def hello
        "hello again"
      end
    end

    klass.message.should == "text"
    klass.new.hello.should == "hello again"
  end
end