describe "Array#zip" do
  it "respects block arity" do
    foo = ['A', 'B']
    values = []

    foo.zip(foo) do | a,b |
      values << [a, b]
    end

    values.should == [['A', 'A'], ['B', 'B']]
  end
end
