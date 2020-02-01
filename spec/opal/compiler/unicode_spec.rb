require 'spec_helper'
require 'opal-parser'

describe Opal::Compiler do
  describe "unicode support" do
    it 'can compile code containing Unicode characters' do
      -> { Opal::Compiler.new("'こんにちは'; p 1").compile }.should_not raise_error
    end
  end
end
