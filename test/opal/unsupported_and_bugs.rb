class Test::Unit::TestCase
  #
  # @example
  #   class TestBase64
  #     unsupported :test_urlsafe_encode64
  #     unsupported :test_strict_encode64
  #   end
  #
  def self.unsupported name, message = 'unsupported'
    define_method name do
      skip message
    end
  end

  #
  # @example
  #   class TestBase64
  #     bug :test_strict_decode64
  #   end
  #
  def self.bug name, message = 'BUG'
    define_method name do
      skip message
    end
  end
end

class TestBase64
  bug :test_strict_decode64
  bug :test_urlsafe_decode64_unpadded
end

class TestCall
  # They work fine if `"a".sub! "b"` is replaced by `[].slice 1`
  unsupported :test_safe_call_block_command
  unsupported :test_safe_call_block_call
  unsupported :test_safe_call_block_call_brace
  unsupported :test_safe_call_block_call_command
end

class TestShellwords
  # TestShellwords#test_multibyte_characters [Assertion: Expected: "\\あ\\い"]:
  # Expected: "\\あ\\い"
  #   Actual: "あい"
  unsupported :test_multibyte_characters

  # TestShellwords#test_backslashes [Assertion: Expected: ["a\\b\\c\\\\d\\\\e a\\b\\c\\\\d\\\\e \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]]:
  # Expected: ["a\\b\\c\\\\d\\\\e a\\b\\c\\\\d\\\\e \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]
  #   Actual: ["a\\b\\c\\\\d\\\\e \\a\\b\\\\c\\\\d\\\\\\e\\ \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]
  bug :test_backslashes

  def test_stringification
    assert_equal "3", shellescape(3)
    pid = rand(1000)
    assert_equal "ps -p #{pid}", ['ps', '-p', pid].shelljoin
  end
end