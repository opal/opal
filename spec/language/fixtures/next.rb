class NextSpecs
  def self.yielding_method(expected)
    yield.should == expected
    :method_return_value
  end
end
