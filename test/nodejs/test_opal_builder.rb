require 'test/unit'
require 'nodejs'
require 'opal-builder'

class TestNodejsOpalBuilder < Test::Unit::TestCase

  def test_should_build_simple_ruby_file
    builder = Opal::Builder.new
    result = builder.build('test/nodejs/fixtures/hello.rb')
    assert(/self\.\$puts\("Hello world"\)/.match(result.to_s))
  end
end
