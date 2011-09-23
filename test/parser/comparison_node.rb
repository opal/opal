require File.expand_path('../../test_helper.rb', __FILE__)

class TestComparisonNode < MiniTest::Unit::TestCase
  def setup
    @native_operators = Opal::Context.new
  end

  # eval using native javascript operators
  def native_eval(str)
    @native_operators.eval str
  end

  def test_native_numeric_eql
    assert_equal "false", native_eval("1 == 2")
    assert_equal "true", native_eval("1 == 1")

    assert_equal "false", native_eval("1 == '1'")
    assert_equal "false", native_eval("1 == '2'")

    assert_equal "true", native_eval("1.0 == 1")

    # Handles bug when calling a method with native type as
    # receiver and it is coerced into a js Number instead of
    # a literal which means it is not === to another number.
    # i.e. `5 === new Number(5)` isnt true. Primatives are
    # coerced when we call a method with one as a receiver
    # therefore being the 'self' value within the method
    native_eval "class Numeric
                     def test_eql_coerce(other)
                       self == other
                     end

                     def test_eql_coerce2(other)
                       other == self
                     end
                   end"

    assert_equal "false", native_eval("1.test_eql_coerce 2")
    assert_equal "true", native_eval("1.test_eql_coerce 1")

    assert_equal "false", native_eval("1.test_eql_coerce2 3")
    assert_equal "true", native_eval("3.test_eql_coerce2 3")
  end
end

