require 'test/unit'
require 'yaml'

class TestYAML < Test::Unit::TestCase
  YAMLDOC = <<~YAML
    ---
    string: hello world
    array: [1,2,3]
  YAML

  YAMLSTRUCT = {
    "string" => "hello world",
    "array" => [1,2,3]
  }

  def test_should_parse_yaml
    assert_equal(YAML.load(YAMLDOC), YAMLSTRUCT)
  end
end
