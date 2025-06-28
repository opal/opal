# backtick_javascript: true

# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/dir'

class TestNodejsDir < Test::Unit::TestCase

  def glob_base_test_dir
    tmpdir + "/testing_nodejs_dir_glob_implementation_#{Time.now.to_i}"
  end

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

  def test_dir_glob_single_directory
    path = glob_base_test_dir + "/single_directory"
    Dir.mkdir(path)
    result = Dir.glob(normalize_glob(path))
    assert_equal(1, result.length)
  end

  def test_dir_glob_any_files_in_directory
    path = glob_base_test_dir + "/any_files_in_directory"
    Dir.mkdir(path)
    result = Dir.glob(normalize_glob(path + '/*'))
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(normalize_glob(path + '/*'))
    assert_equal(result.length, 2)
  end

  def test_dir_glob_start_with_files_in_directory
    path = glob_base_test_dir + "/start_with_files_in_directory"
    Dir.mkdir(path)
    result = Dir.glob(normalize_glob(path + '/*'))
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(normalize_glob(path + '/ba*'))
    assert_equal(2, result.length)
  end

  def test_dir_glob_end_with_files_in_directory
    path = glob_base_test_dir + "/end_with_files_in_directory"
    Dir.mkdir(path)
    result = Dir.glob(normalize_glob(path + '/*'))
    assert_equal(result.length, 0)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(normalize_glob(path + '/*z'))
    assert_equal(1, result.length)
  end

  def test_dir_glob_specific_files
    path = glob_base_test_dir + "/specific_files"
    Dir.mkdir(path)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob([normalize_glob(path + '/baz'), normalize_glob(path + '/bar')])
    assert_equal(2, result.length)
    result = Dir.glob(normalize_glob(path))
    assert_equal(1, result.length)
  end

  def test_dir_glob_include_subdir
    base_path = glob_base_test_dir + "/include_subdir"
    path = base_path + "/subdir"
    Dir.mkdir(path)
    Dir.mkdir(path)
    File.open(path + '/bar', "w") {}
    File.open(path + '/baz', "w") {}
    result = Dir.glob(normalize_glob(base_path + '/*/*'))
    assert_equal(2, result.length)
  end

  def test_dir_glob_recursive
    base_path = glob_base_test_dir + "/recursive"
    Dir.mkdir(base_path)
    File.open(base_path + '/1', "w") {}
    File.open(base_path + '/2', "w") {}
    path = base_path + "/subdir"
    Dir.mkdir(path)
    File.open(path + '/3', "w") {}
    File.open(path + '/4', "w") {}
    result = Dir.glob(normalize_glob(base_path + '/**/*'))
    assert_equal(5, result.length)
  end

  def test_dir_glob_any_directories
    base_path = glob_base_test_dir + "/recursive"
    Dir.mkdir(base_path)
    File.open(base_path + '/1', "w") {}
    File.open(base_path + '/2', "w") {}
    path = base_path + "/subdir"
    Dir.mkdir(path)
    File.open(path + '/3', "w") {}
    File.open(path + '/4', "w") {}
    result = Dir.glob(normalize_glob(base_path + '/**'))
    assert_equal(3, result.length)
  end

  def test_dir_glob_single_depth
    base_path = glob_base_test_dir + "/single_depth"
    Dir.mkdir(base_path)
    File.open(base_path + '/1', "w") {}
    File.open(base_path + '/2', "w") {}
    path = base_path + "/subdir"
    Dir.mkdir(path)
    File.open(path + '/3', "w") {}
    File.open(path + '/4', "w") {}
    result = Dir.glob(normalize_glob(base_path + '/*/*'))
    assert_equal(2, result.length)
  end

  def test_dir_glob_multiple_depth
    base_path = glob_base_test_dir + "/multiple_depth"
    path = base_path + "/1/2/3"
    Dir.mkdir(path)
    File.open(path + '/foo', "w") {}
    File.open(path + '/bar', "w") {}
    result = Dir.glob(normalize_glob(base_path + '/**/foo'))
    assert_equal(1, result.length)
    result = Dir.glob(normalize_glob(base_path + '/**/*'))
    assert_equal(5, result.length)
  end
end
