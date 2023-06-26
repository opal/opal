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

class TestBenchmark
  # sleep is unsupported if not awaited
  unsupported :test_realtime_output
  bug :test_bugs_ruby_dev_40906_can_add_in_place_the_time_of_execution_of_the_block_given
end

class TestData
  # our hash is not fixnum
  unsupported :test_instance_behavior
end
