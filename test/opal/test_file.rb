# backtick_javascript: true

# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'tmpdir'

class TestOpalFile < Test::Unit::TestCase
  def self.windows_platform?
    RUBY_PLATFORM.include?('win') && !RUBY_PLATFORM.include?('darwin')
  end

  def test_instantiate_without_open_mode
    # By default the open mode is 'r' (read only)
    File.write('tmp/quz', "world")
    file = File.new('tmp/quz')
    assert_equal('tmp/quz', file.path)
  end

  def test_mtime
    File.write('tmp/qix', "hello")
    file = 'tmp/qix'
    File.new(file, 'r')

    t1 = File.mtime(file)
    t2 = File.open(file) {|f| f.mtime}
    assert_kind_of(Time, t1)
    assert_kind_of(Time, t2)
    assert_equal(t1, t2)
    assert_raise(Errno::ENOENT) { File.mtime('nofile') }
  end

  def test_write_read
    path = Dir.tmpdir + "/testing_nodejs_file_implementation_#{Time.now.to_i}"
    contents = 'foobar'
    assert !File.exist?(path)
    File.write path, contents

    assert_equal(contents, File.read(path))
  end

  def test_read_file
    File.write('tmp/foo', 'bar')
    assert_equal('bar', File.read('tmp/foo'))
  end

  def test_read_binary_image
    assert_match(/^\u0089PNG\r\n\u001A\n\u0000\u0000\u0000\rIHDR.*/, File.open('./test/opal/fixtures/cat.png', 'rb') {|f| f.read })
  end

  def test_read_binary_utf8_file
    binary_text = ::File.open('./test/opal/fixtures/utf8.txt', 'rb') {|f| f.read}
    assert_equal(binary_text.encoding, Encoding::ASCII_8BIT)
    assert_match(/^\xC3\xA7\xC3\xA9\xC3\xA0/, binary_text)
    assert_equal("çéà".bytes, binary_text.bytes)
    utf8_text = binary_text.force_encoding('utf-8')
    assert_equal("çéà", utf8_text)
  end

  def test_read_binary_iso88591_file
    binary_text = ::File.open('./test/opal/fixtures/iso88591.txt', 'rb') {|f| f.read}
    assert_equal(binary_text.encoding, Encoding::ASCII_8BIT)
    assert_match(/^\u00E7\u00E9\u00E0/, binary_text)
    utf8_text = binary_text.force_encoding('utf-8')
    assert_equal("çéà", utf8_text)
  end

  def test_read_binary_win1258_file
    binary_text = ::File.open('./test/opal/fixtures/win1258.txt', 'rb') {|f| f.read}
    assert_equal(binary_text.encoding, Encoding::ASCII_8BIT)
    assert_match(/^\u00E7\u00E9\u00E0/, binary_text)
    utf8_text = binary_text.force_encoding('utf-8')
    assert_equal("çéà", utf8_text)
  end

  def test_read_each_line
    File.write('tmp/bar', "one\ntwo")
    file = File.new('tmp/bar', 'r')
    lines = []
    file.each_line do |line|
      lines << line
    end
    assert_equal(2, lines.length)
    assert_equal("one\n", lines[0])
    assert_equal('two', lines[1])
  end

  def test_readlines
    File.write('tmp/quz', "one\ntwo")
    file = File.new('tmp/quz', 'r')
    lines = file.readlines
    assert_equal(2, lines.length)
    assert_equal("one\n", lines[0])
    assert_equal('two', lines[1])
  end

  def test_readlines_separator
    File.write('tmp/qux', "one-two")
    file = File.new('tmp/qux', 'r')
    lines = file.readlines '-'
    assert_equal(2, lines.length)
    assert_equal('one-', lines[0])
    assert_equal('two', lines[1])
  end

  def test_read_noexistent_should_raise_io_error
    assert_raise Errno::ENOENT do
      File.read('tmp/nonexistent')
    end
  end

  def test_mtime_noexistent_should_raise_io_error
    assert_raise(Errno::ENOENT) { File.mtime('tmp/nonexistent') }
  end

  def test_current_directory_should_be_a_directory
    assert(File.directory?('.'))
  end

  def test_current_directory_should_be_a_directory_using_pathname
    current_dir = Pathname.new('.')
    assert(current_dir.directory?)
  end

  def test_directory_check
    refute(File.directory?('test/opal/fixtures/non-existent'),          'test/opal/fixtures/non-existent should not be a directory')
    assert(File.directory?('test/opal/fixtures/'),                      'test/opal/fixtures/ should be a directory')
    assert(File.directory?('test/opal/fixtures'),                       'test/opal/fixtures should be a directory')
    refute(File.directory?('test/opal/fixtures/hello.rb'),              'test/opal/fixtures/hello.rb should not be a directory')
  end

  # Let's not ship our repo with symlinks, but create them on the go
  def with_symlinks(&block)
    dir_symlink = 'test/opal/fixtures/symlink-to-directory'
    file_symlink = 'test/opal/fixtures/symlink-to-file'

    File.symlink('.', dir_symlink)
    File.symlink('hello.rb', file_symlink)
    block.call(dir_symlink, file_symlink)
  ensure
    File.unlink(dir_symlink)
    File.unlink(file_symlink)
  end

  def test_directory_check_with_symlinks
    with_symlinks do |dir_symlink, file_symlink|
      assert(File.directory?(dir_symlink),     dir_symlink+' should be a directory')
      assert(File.directory?(dir_symlink+'/'), dir_symlink+'/ should be a directory')
      refute(File.directory?(file_symlink),    file_symlink+' should not be a directory')
    end
  end unless windows_platform?

  def test_file_check
    refute(File.file?('test/opal/fixtures/non-existent'),          'test/opal/fixtures/non-existent should not be a file')
    refute(File.file?('test/opal/fixtures/'),                      'test/opal/fixtures/ should not be a file')
    refute(File.file?('test/opal/fixtures'),                       'test/opal/fixtures should not be a file')
    assert(File.file?('test/opal/fixtures/hello.rb'),              'test/opal/fixtures/hello.rb should be a file')
  end

  def test_file_check_with_symlinks
    with_symlinks do |dir_symlink, file_symlink|
      refute(File.file?(dir_symlink),     dir_symlink+' should not be a file')
      refute(File.file?(dir_symlink+'/'), dir_symlink+'/ should not be a file')
      assert(File.file?(file_symlink),    file_symlink+' should be a file')
    end
  end unless windows_platform?

  def test_file_symlink?
    with_symlinks do |dir_symlink, file_symlink|
      assert(File.symlink?(file_symlink))
      assert(File.symlink?(dir_symlink))
      refute(File.symlink?('test/opal/fixtures'))
      refute(File.symlink?('test/opal/fixtures/hello.rb'))
    end
  end unless windows_platform?

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
    # do not use d: because its a symlink in github actions fs, leading to unexpected results
    drive_letter = Dir.pwd.slice(0, 2)
    assert_equal(Dir.pwd + '/foo/bar.js', File.expand_path('./foo/bar.js'))
    assert_equal(drive_letter + '/foo/bar.js', File.expand_path('/foo/bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path('c:/foo/bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path('c:\\foo\\bar.js'))
    assert_equal('c:/foo/bar.js', File.expand_path('bar.js', 'c:\\foo'))
    assert_equal('c:/baz/bar.js', File.expand_path('\\baz\\bar.js', 'c:\\foo'))
    assert_equal('c:/bar.js', File.expand_path('\\..\\bar.js', 'c:\\foo\\baz'))
    assert_equal('c:/bar.js', File.expand_path('\\..\\bar.js', 'c:\\foo\\baz\\'))
    assert_equal('c:/foo/baz/bar.js', File.expand_path('baz\\bar.js', 'c:\\foo'))
    assert_equal('c:/baz/bar.js', File.expand_path('baz\\bar.js', 'c:\\foo\\..'))
    assert_equal('f:/', File.expand_path('f:'), 'should add a trailing slash when the path is d:')
    assert_equal('g:/', File.expand_path('g:/'), 'should preserve the trailing slash when the path d:/')
    assert_equal(Dir.pwd, File.expand_path(drive_letter), 'should expand to the current directory when the path is c: (and the current directory is located in the c drive)')
    assert_equal(drive_letter + '/', drive_letter + '/', 'should return c:/ when the path is c:/ because the path is absolute')
  end if windows_platform?

  def test_linux_file_expand_path
    assert_equal(Dir.pwd + '/foo/bar.js', File.expand_path('./foo/bar.js'))
    assert_equal(Dir.home + '/foo/bar.js', File.expand_path('~/foo/bar.js'))
    assert_equal(Dir.home + '/foo/bar.js', File.expand_path('~/foo/bar.js', '/base/dir'))
    assert_equal('/base/dir/foo/bar.js', File.expand_path('./foo/bar.js', '/base/dir'))
    assert_equal(Dir.home + '/workspace/foo/bar.js', File.expand_path('./foo/bar.js', '~/workspace'))
  end unless windows_platform?

  def test_join
    assert_equal('usr/bin', File.join('usr', 'bin'))
    assert_equal('//a/b', File.join('//a', 'b'))
  end

  def test_join_supports_any_number_of_arguments
    assert_equal("a/b/c/d", File.join("a", "b", "c", "d"))
  end

  def test_join_handles_leading_parts_edge_cases
    assert_equal("/bin", File.join("/bin"))
    assert_equal("/bin", File.join("/", "bin"))
    assert_equal("/bin", File.join("/", "/bin"))
  end
end
