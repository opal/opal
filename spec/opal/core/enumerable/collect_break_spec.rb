describe "Enumerable#collect" do
  class Test
    include Enumerable

    def each(&block)
      [1, 2, 3].each(&block)
    end
  end

  it "breaks out with the proper value" do
    expect(Test.new.collect { break 42 }).to eq(42)
  end
end
