describe 'Opal.is_a' do
  describe 'Numeric/Number special cases' do
    [
      [1, Numeric, true],
      [1, Number, true],
      [1, Fixnum, true],
      [1, Integer, true],
      [1, Float, true],

      [1.2, Numeric, true],
      [1.2, Number, true],
      [1.2, Fixnum, true],
      [1.2, Integer, true],
      [1.2, Float, true],

      [Numeric.new, Numeric, true],
      [Numeric.new, Number, false],
      [Numeric.new, Fixnum, false],
      [Numeric.new, Integer, false],
      [Numeric.new, Float, false],
    ].each do |(value, klass, result)|
      it "returns #{result} for Opal.is_a(#{value}, #{klass})" do
        # p klass => `[!!klass.$$is_number_class, !!klass.$$proto.$$is_number]`
        `Opal.is_a(#{value}, #{klass})`.should == result
      end
    end

    it 'can rely on Number subclasses having $$is_number_class on their prototype' do
      `!!#{Numeric}.$$is_number_class`.should == false
      `!!#{Number}.$$is_number_class`.should == true
      `!!#{Fixnum}.$$is_number_class`.should == true
      `!!#{Integer}.$$is_number_class`.should == true
      `!!#{Float}.$$is_number_class`.should == true
    end
  end
end
