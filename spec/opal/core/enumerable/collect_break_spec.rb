describe "Enumerable#collect" do
  class Test
    include Enumerable

    def each(&block)
      [1, 2, 3].each(&block)
    end
  end

  it "breaks out with the proper value" do
    Test.new.collect { break 42 }.should == 42
  end
end
