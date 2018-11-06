require 'test/unit'
require 'nodejs'

class TestNodejsPathname < Test::Unit::TestCase
  def self.windows_platform?
    `process.platform`.start_with?('win')
  end

  def test_windows_pathname_absolute
    assert_equal(true, Pathname.new('c:/foo').absolute?)
    assert_equal(true, Pathname.new('/foo').absolute?)
    assert_equal(true, Pathname.new('\\foo').absolute?)
    assert_equal(false, Pathname.new('.').absolute?)
    assert_equal(false, Pathname.new('foo').absolute?)
  end if windows_platform?
end
