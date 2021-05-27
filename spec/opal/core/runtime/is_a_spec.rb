describe 'Opal.is_a' do
  describe 'Numeric/Number special cases' do
    [
      [1, :Numeric, true],
      [1, :Number, true],
      [1, :Fixnum, true],
      [1, :Integer, true],
      [1, :Float, true],

      [1.2, :Numeric, true],
      [1.2, :Number, true],
      [1.2, :Fixnum, true],
      [1.2, :Integer, false],
      [1.2, :Float, true],

      [Numeric.new, :Numeric, true],
      [Numeric.new, :Number, false],
      [Numeric.new, :Fixnum, false],
      [Numeric.new, :Integer, false],
      [Numeric.new, :Float, false],
    ].each do |(value, klass_name, result)|
      klass = Object.const_get(klass_name)
      it "returns #{result} for Opal.is_a(#{value}, #{klass_name})" do
        `Opal.is_a(#{value}, #{klass})`.should == result
      end
    end

    it 'can rely on Number subclasses having $$is_number_class on their prototype' do
      `!!#{Numeric}[Opal.s.$$is_number_class]`.should == false
      `!!#{Number}[Opal.s.$$is_number_class]`.should == true
      `!!#{Fixnum}[Opal.s.$$is_number_class]`.should == true
      `!!#{Integer}[Opal.s.$$is_number_class]`.should == true
      `!!#{Float}[Opal.s.$$is_number_class]`.should == true
    end

    it 'can rely on Number subclasses having $$is_integer_class_s on their prototype' do
      `!!#{Numeric}[Opal.s.$$is_integer_class]`.should == false
      `!!#{Number}[Opal.s.$$is_integer_class]`.should == false
      `!!#{Fixnum}[Opal.s.$$is_integer_class]`.should == false
      `!!#{Integer}[Opal.s.$$is_integer_class]`.should == true
      `!!#{Float}[Opal.s.$$is_integer_class]`.should == false
    end

    it 'works for non-Opal objects' do
      `Opal.is_a({}, Opal.Array)`.should == false
    end
  end
end
