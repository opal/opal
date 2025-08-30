require 'test/unit'
require 'opal-builder'

class TestOpalOpalBuilder < Test::Unit::TestCase

  def test_should_build_simple_ruby_file
    builder = Opal::Builder.new
    builder.append_paths('.')
    result = builder.build('test/opal/fixtures/hello.rb')
    assert(/self\.\$puts\("Hello world"\)/.match(result.to_s))
  end
end
