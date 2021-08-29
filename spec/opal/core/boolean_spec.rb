require 'spec_helper'

describe "TrueClass/FalseClass" do
  it 'correctly resolves a boolean class' do
    expect(true.class).to eq(TrueClass)
    expect(false.class).to eq(FalseClass)

    expect(true.class).not_to eq(false.class)
  end

  it 'correctly resolves a boolean class with #is_a?' do
    expect(true.is_a? TrueClass).to be_true
    expect(false.is_a? FalseClass).to be_true
    expect(false.is_a? TrueClass).to be_false
    expect(true.is_a? FalseClass).to be_false
  end

  it 'correctly resolves a boolean class with #===' do
    expect(TrueClass === true).to be_true
    expect(FalseClass === false).to be_true
    expect(TrueClass === false).to be_false
    expect(FalseClass === true).to be_false
    expect(TrueClass === 6).to be_false
    expect(true === true).to be_true
    expect(false === false).to be_true
  end

  it 'allows defining methods on TrueClass/FalseClass' do
    class TrueClass
      def test_opal
        false
      end
    end

    class FalseClass
      def test_opal
        true
      end
    end

    expect(true.test_opal).to be_false
    expect(false.test_opal).to be_true
  end
end
