describe "A Symbol literal" do
  it "can be an empty string" do
    c = :''
    expect(c).to be_kind_of(Symbol)
    expect(c.inspect).to eq(':""')
  end

  # These weren't allowed on 1.8
  it "can be :!, :!=, or :!~" do
    %w{'!', '!=', '!~'}.each do |sym|
      expect { sym.to_sym }.not_to raise_error
      expect(sym.to_sym.to_s).to eq(sym)
    end
  end
end
