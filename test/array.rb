require 'test/unit'

class TestArray < Test::Unit::TestCase

  def test_allocate
    ary = Array.allocate
    assert ary.is_a? Array

    ary2 = Array.allocate
    assert ary2.length == 0
  end

  def test_first
    assert_equal 'a', ['a', 'b', 'c'].first
    assert_equal nil, [nil].first

    assert_equal nil, [].first

    assert_equal [true, false], [true, false, true, nil, false].first(2)

    assert_equal [], [].first(0)
    assert_equal [], [].first(1)
    assert_equal [], [].first(2)

    assert_equal [], [1, 2, 3, 4, 5].first(0)

    assert_equal [1], [1, 2, 3, 4, 5].first(1)

    assert_equal [1, 2, 3, 4, 5, 9], [1, 2, 3, 4, 5, 9].first(10)

    a = [1, 2, 3]
    a.first
    assert_equal [1, 2, 3], a

    a.first(2)
    assert_equal [1, 2, 3], a

    a.first(3)
    assert_equal [1, 2, 3], a
  end

  def test_length
    assert_equal 0, [].length
    assert_equal 3, [1, 4, 2].length
    assert_equal 2, [1, nil].length
    assert_equal 1, [nil].length
  end

  def test_size
    assert_equal 0, [].length
    assert_equal 3, [1, 4, 2].length
    assert_equal 2, [1, nil].length
    assert_equal 1, [nil].length
  end
end

