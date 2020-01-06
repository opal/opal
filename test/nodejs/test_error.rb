require 'test/unit'
require 'nodejs'

class TestNodejsError < Test::Unit::TestCase

  def test_should_preserve_stack
    raise ArgumentError.new('oops')
  rescue => ex
    backtrace_line = "at nodejs/test_error.rb:#{__LINE__ - 2}"
    wrapped_ex = ex.exception %(context - #{ex.message})
    assert(`wrapped_ex.stack`.include?(backtrace_line))
  end

  def test_should_set_stack
    raise ArgumentError.new('oops')
  rescue => ex
    backtrace_line = "at nodejs/test_error.rb:#{__LINE__ - 2}"
    wrapped_ex = ex.exception %(context - #{ex.message})
    wrapped_ex.set_backtrace ex.backtrace
    assert(`wrapped_ex.stack`.include?(backtrace_line))
  end

  def test_should_get_stack
    raise ArgumentError.new('oops')
  rescue => ex
    backtrace_line = "at nodejs/test_error.rb:#{__LINE__ - 2}"
    assert(`ex.stack`.include?(backtrace_line))
  end
end
