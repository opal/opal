# backtick_javascript: true

# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/dir'

class TestNodejsDir < Test::Unit::TestCase

  def tmpdir
    `require('os').tmpdir()`
  end

  def normalize_glob(path)
    path.gsub "\\", "/"
  end

  def test_dir_entries
    path = tmpdir + "/testing_nodejs_dir_entries_implementation_#{Time.now.to_i}"
    Dir.mkdir(path)
    result = Dir.entries(path)
    assert_equal(0, result.length)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.entries(path)
    assert_equal(2, result.length)
  end
  
  def test_dir_glob
    path = tmpdir + "/testing_nodejs_dir_glob_implementation_#{Time.now.to_i}"
    Dir.mkdir(path)
    result = Dir.glob(normalize_glob(path + '/*'))
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(normalize_glob(path + '/ba*'))
    assert_equal(2, result.length)
    result = Dir.glob(normalize_glob(path + '/*z'))
    assert_equal(1, result.length)
    result = Dir.glob([normalize_glob(path + '/baz'), normalize_glob(path + '/bar')])
    assert_equal(2, result.length)
  end
end
