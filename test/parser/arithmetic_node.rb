require File.expand_path('../../test_helper.rb', __FILE__)

class TestArithmeticNode < MiniTest::Unit::TestCase

  def test_native_arithmetic_operators
    native_eval "class Numeric
                   def +(other); 'using overload!'; end
                   alias_method :-, :+
                   alias_method :*, :+
                   alias_method :/, :+
                   alias_method :%, :+
                 end"

    assert_equal "7", native_eval("3 + 4")
    assert_equal "-1", native_eval("3 - 4")
    assert_equal "12", native_eval("3 * 4")
    assert_equal "1", native_eval("10 % 3")
  end
end

