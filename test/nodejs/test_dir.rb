# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/dir'

class TestNodejsDir < Test::Unit::TestCase

  def tmpdir
    `require('os').tmpdir()`
  end

  def test_dir_entries
    path = tmpdir + "/testing_nodejs_dir_entries_implementation_#{Time.now.to_i}"
    Dir.mkdir(path)
    result = Dir.entries(path)
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.entries(path)
    assert_equal(result.length, 2)
  end
  
  def test_dir_glob
    path = tmpdir + "/testing_nodejs_dir_glob_implementation_#{Time.now.to_i}"
    Dir.mkdir(path)
    result = Dir.glob(path + '/*')
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(path + '/ba*')
    assert_equal(result.length, 2)
    result = Dir.glob(path + '/*z')
    assert_equal(result.length, 1)
    result = Dir.glob([path + '/baz', path + '/bar'])
    assert_equal(result.length, 2)
    result = Dir.glob(Pathname.new(path).join('*'))
    assert_equal(result.length, 2)
  end
end
