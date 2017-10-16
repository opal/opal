# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/file'

class TestNodejsFile < Test::Unit::TestCase
  def tmpdir
    `require('os').tmpdir()`
  end

  def self.windows_platform?
    `process.platform`.start_with?('win')
  end

  def test_instantiate_without_open_mode
    # By default the open mode is 'r' (read only)
    File.write('tmp/quz', "world")
    file = File.new('tmp/quz')
    assert_equal('tmp/quz', file.path)
  end

  def test_mtime
    File.write('tmp/qix', "hello")
    file = File.new('tmp/qix', 'r')
    file_mtime = file.mtime
    assert(Time.now >= file_mtime, 'File modification time should be before now')
  end

  def test_write_read
    path = tmpdir + "/testing_nodejs_file_implementation_#{Time.now.to_i}"
    contents = 'foobar'
    assert !File.exist?(path)
    File.write path, contents

    assert_equal(contents, File.read(path))
  end

  def test_read_file
    File.write('tmp/foo', 'bar')
    assert_equal("bar", File.read('tmp/foo'))
  end

  def test_read_each_line
    File.write('tmp/bar', "one\ntwo")
    file = File.new('tmp/bar', 'r')
    lines = []
    file.each_line do |line|
      lines << line
    end
    assert_equal(lines.length, 2)
  end

  def test_read_noexistent_should_raise_io_error
    assert_raise IOError do
      File.read('tmp/nonexistent')
    end
  end

  def test_mtime_noexistent_should_raise_io_error
    assert_raise IOError do
      File.mtime('tmp/nonexistent')
    end
  end

  def test_current_directory_should_be_a_directory
    assert(File.directory?('.'))
  end

  def test_current_directory_should_be_a_directory_using_pathname
    current_dir = Pathname.new('.');
    assert(current_dir.directory?)
  end

  def test_file_readable
    assert !File.readable?('tmp/nonexistent')
    File.write('tmp/fuz', "hello")
    assert File.readable?('tmp/fuz')
  end

  def test_linux_separators
    assert_equal('/', File::SEPARATOR)
    assert_equal('/', File::Separator)
    assert_equal(nil, File::ALT_SEPARATOR)
  end unless windows_platform?

  def test_windows_separators
    assert_equal('/', File::SEPARATOR)
    assert_equal('/', File::Separator)
    assert_equal('\\', File::ALT_SEPARATOR)
  end if windows_platform?

  def test_windows_file_expand_path
    assert_equal(Dir.pwd.gsub(/\\/, '/') + '/foo/bar.js', File.expand_path('./foo/bar.js'))
    assert_equal('/foo/bar.js', File.expand_path('/foo/bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path('c:/foo/bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path('c:\\foo\\bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path( 'bar.js', 'c:\\foo'))
    assert_equal('c:/foo/baz/bar.js', File.expand_path('\\baz\\bar.js', 'c:\\foo'))
    assert_equal('c:/baz/bar.js', File.expand_path( '\\baz\\bar.js', 'c:\\foo\\..'))
    assert_equal('c:/foo/bar.js', File.expand_path( '\\..\\bar.js', 'c:\\foo\\baz'))
    assert_equal('c:/foo/bar.js', File.expand_path( '\\..\\bar.js', 'c:\\foo\\baz\\'))
  end if windows_platform?
end
