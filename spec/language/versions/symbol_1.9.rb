describe "A Symbol literal" do
  pending "can be an empty string" do
    c = :''
    c.should be_kind_of(Symbol)
    c.inspect.should == ':""'
  end

  # These weren't allowed on 1.8
  pending "can be :!, :!=, or :!~" do
    %w{'!', '!=', '!~'}.each do |sym|
      lambda { sym.to_sym }.should_not raise_error(SyntaxError)
      sym.to_sym.to_s.should == sym
    end
  end
end
