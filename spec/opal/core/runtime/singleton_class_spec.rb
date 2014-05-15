require 'spec_helper'

class SingletonClassConstantsSpec
  class << self
    $singleton_class_constant_spec = String
  end
end

describe "Singleton Classes" do
  it "looks up constants in body" do
    expect($singleton_class_constant_spec).to eq(String)
  end
end
