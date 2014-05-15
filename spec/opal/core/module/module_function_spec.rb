describe "Module#module_function with specific method names" do
  it "creates duplicates of the given instance methods on the Module object" do
    m = Module.new do
      def test()  end
      def test2() end
      def test3() end

      module_function :test, :test2
    end

    expect(m.respond_to?(:test)).to  eq(true)
    expect(m.respond_to?(:test2)).to eq(true)
    expect(m.respond_to?(:test3)).to eq(false)
  end

  it "returns the current module" do
    x = nil
    m = Module.new do
      def test()  end
      x = module_function :test
    end

    expect(x).to eq(m)
  end
end
