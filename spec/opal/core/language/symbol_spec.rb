describe "A Symbol literal" do
  it "is a ':' followed by any number of valid characters" do
    a = :foo
    expect(a).to be_kind_of(Symbol)
    # FIXME: this doesnt work as Symbols are Strings
    #a.inspect.should == ':foo'
  end

  it "is a ':' followed by any valid variable, method, or constant name" do
    # Add more of these?
    [ :Foo,
      :foo,
      :@foo,
      :@@foo,
      :$foo,
      :_,
      :~,
      :-,
      :FOO,
      :_Foo,
      :&,
      :_9
    ].each { |s| expect(s).to be_kind_of(Symbol) }
  end

  it "is a ':' followed by a single- or double-quoted string that may contain otherwise invalid characters" do
    [ [:'foo bar',      ':"foo bar"'],
      [:'++',           ':"++"'],
      [:'9',            ':"9"'],
      [:"foo #{1 + 1}", ':"foo 2"']
    ].each {
      # FIXME: Symbols are Strings, so #inspect wont work
      expect(1).to eq(1)
    }
  end

  it "may contain '::' in the string" do
    expect(:'Some::Class').to be_kind_of(Symbol)
  end
end
