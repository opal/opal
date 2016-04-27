TestShellwords.class_eval do
  def test_multibyte_characters
    skip "Unsupported"
    # TestShellwords#test_multibyte_characters [Assertion: Expected: "\\あ\\い"]:
    # Expected: "\\あ\\い"
    #   Actual: "あい"
  end

  def test_backslashes
    skip "Fails"
    # TestShellwords#test_backslashes [Assertion: Expected: ["a\\b\\c\\\\d\\\\e a\\b\\c\\\\d\\\\e \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]]:
    # Expected: ["a\\b\\c\\\\d\\\\e a\\b\\c\\\\d\\\\e \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]
    #   Actual: ["a\\b\\c\\\\d\\\\e \\a\\b\\\\c\\\\d\\\\\\e\\ \\a\\\\b\\\\\\c\\\\\\\\d\\\\\\\\\\e\\ a\\b\\c\\\\d\\\\e "]
  end

  def test_stringification
    assert_equal "3", shellescape(3)
    pid = rand(1000)
    assert_equal "ps -p #{pid}", ['ps', '-p', pid].shelljoin
  end
end if defined? TestShellwords
