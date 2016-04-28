# Copied from cruby and modified to skip unsupported syntaxes
require 'test/unit'
require 'nodejs'
require 'nodejs/file'

class TestNodejsFile < Test::Unit::TestCase
  def test_write_read
    path = '/tmp/testing_nodejs_file_implementation'
    contents = 'foobar'
    assert !File.exist?(path)
    File.write path, contents

    assert_equal(contents, File.read(path))
  end
end
