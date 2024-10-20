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

class TestBenchmark
  # sleep is unsupported if not awaited
  unsupported :test_realtime_output
  bug :test_bugs_ruby_dev_40906_can_add_in_place_the_time_of_execution_of_the_block_given
end

class TestIOBuffer
  # mmap is not supported, modifying Strings is not supported,
  # but many below are just issues with Tempfile
  unsupported :test_file_mapped
  unsupported :test_invalidation
  unsupported :test_new_mapped
  unsupported :test_read
  unsupported :test_read_with_with_offset
  unsupported :test_read_with_with_length
  unsupported :test_pread
  unsupported :test_pread_offset
  unsupported :test_private
  unsupported :test_pwrite
  unsupported :test_pwrite_offset
  unsupported :test_read_with_length_and_offset
  unsupported :test_shared
  unsupported :test_string_mapped_buffer_locked
  unsupported :test_string_mapped_mutable
  unsupported :test_transfer_in_block
  unsupported :test_write
  unsupported :test_write_with_length_and_offset
  # also check commented lines in RANGES in test_io_buffer.rb
end