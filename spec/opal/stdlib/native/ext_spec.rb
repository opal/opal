require 'native'

describe Hash do
  describe '#initialize' do
    it "returns a hash with a nil value" do
      h = Hash.new(`{a: null}`)
      expect(h[:a]).to eq(nil)
    end
  end

  describe '#to_n' do
    it "should return a js object representing hash" do
      expect(Hash.new({:a => 100, :b => 200}.to_n)).to eq({:a => 100, :b => 200})
    end
  end
end

describe "Hash#to_n" do
end
