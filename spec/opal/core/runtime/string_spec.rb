require 'spec_helper'

describe "Runtime String helpers" do
  context 'Opal.enc' do
    it 'sets the encoding boxing literal strings' do
      -> {
        `Opal.enc("foo", 'UTF-8')`
      }.should_not raise_error
    end
  end

  context 'Opal.set_encoding' do
    it 'sets the encoding for boxed strings' do
      expect(`Opal.set_encoding(new String("foo"), 'UTF-8')`.encoding).to eq(Encoding::UTF_8)
      expect(`Opal.set_encoding("foo".$dup(), 'UTF-8')`.encoding).to eq(Encoding::UTF_8)
      expect(`Opal.set_encoding("foo".$clone(), 'UTF-8')`.encoding).to eq(Encoding::UTF_8)
    end

    it 'raises FrozenError when provided a literal' do
      -> {
        `Opal.set_encoding("foo", 'UTF-8')`
      }.should raise_error(FrozenError)
    end
  end
end
