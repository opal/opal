# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/dir'

class TestNodejsDir < Test::Unit::TestCase
  def test_dir_entries
    path = "/tmp/testing_nodejs_dir_implementation_#{Time.now.to_i}"
    Dir.mkdir(path)
    result = Dir.entries(path)
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.entries(path)
    assert_equal(result.length, 2)
  end
end
