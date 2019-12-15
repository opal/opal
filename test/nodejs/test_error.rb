require 'test/unit'
require 'nodejs'

class TestNodejsError < Test::Unit::TestCase

  def test_should_preserve_stack
    raise ArgumentError.new('oops')
  rescue => ex
    wrapped_ex = ex.exception %(context - #{ex.message})
    assert_match(/at constructor\.\$\$test_should_preserve_stack/, `wrapped_ex.stack`)
  end

  def test_should_set_stack
    raise ArgumentError.new('oops')
  rescue => ex
    wrapped_ex = ex.exception %(context - #{ex.message})
    wrapped_ex.set_backtrace ex.backtrace
    assert_match(/at constructor\.\$\$test_should_set_stack/, `wrapped_ex.stack`)
  end

  def test_should_get_stack
    raise ArgumentError.new('oops')
  rescue => ex
    assert_match(/at constructor\.\$\$test_should_get_stack/, `ex.stack`)
  end
end
