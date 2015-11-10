describe "Kernel#instance_variables" do
  context 'for nil' do
    it 'returns blank array' do
      expect(nil.instance_variables).to eq([])
    end
  end

  context 'for string' do
    it 'returns blank array' do
      expect(''.instance_variables).to eq([])
    end
  end

  context 'for hash' do
    it 'returns blank array' do
      expect({}.instance_variables).to eq([])
    end
  end

  context 'for object' do
    it 'returns blank array' do
      expect(Object.new.instance_variables).to eq([])
    end
  end

  context 'for object with js keyword as instance variables' do
    reserved_keywords = %w(
      @constructor
      @__proto__
      @__parent__
      @__noSuchMethod__
      @__count__
      @hasOwnProperty
      @valueOf
    )

    reserved_keywords.each do |ivar|
      context "#{ivar} as instance variable name" do
        it "returns non-escaped #{ivar} in instance_variables list" do
          obj = Object.new
          obj.instance_variable_set(ivar, 'value')

          expect(obj.instance_variables).to eq([ivar])
        end
      end
    end
  end
end
