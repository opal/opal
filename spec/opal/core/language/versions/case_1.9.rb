describe "The 'case'-construct" do
  it "takes multiple expanded arrays" do
    a1 = ['f', 'o', 'o']
    a2 = ['b', 'a', 'r']

    case 'f'
      when *a1, *['x', 'y', 'z']
        "foo"
      when *a2, *['x', 'y', 'z']
        "bar"
    end.should == "foo"

    case 'b'
      when *a1, *['x', 'y', 'z']
        "foo"
      when *a2, *['x', 'y', 'z']
        "bar"
    end.should == "bar"
  end
end
