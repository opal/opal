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

class TestOpalError
  if %w[firefox safari].include?(::Opal.JS[:platform].JS[:name])
    bug :test_should_get_stack
    bug :test_should_preserve_stack
    bug :test_should_set_stack
  end
end

# These are only supposed to work on node compatible platforms
if %w[node nodejs].include?(::Opal.JS[:platform].JS[:name])
  class TestEtc
    unsupported :test_ractor
  end

  class TestFileUtils
    # mostly NotImplementedError: Thread creation not available
    unsupported :test_assert_output_lines
    unsupported :test_chdir_verbose
    unsupported :test_chmod_verbose
    unsupported :test_chown
    unsupported :test_chown_dir_group_ownership_not_recursive
    unsupported :test_chown_noop
    unsupported :test_chown_R
    unsupported :test_chown_R_force
    unsupported :test_chown_R_noop
    unsupported :test_chown_R_verbose
    unsupported :test_chown_verbose
    unsupported :test_s_chmod_verbose
    if ::Opal.JS[:platform].JS[:macos]
      # tests expect EPERM but nodejs chown throws range error for user id -2,
      # which is the valid user id of the user nobody on macos
      bug :test_chown_R_without_permission
      bug :test_chown_without_permission
    elsif ::Opal.JS[:platform].JS[:windows]
      bug :test_cp_symlink # no error
      bug :test_install_symlink # no error
      bug :test_install_symlink # no error
      bug :test_mkdir # throwing EPERM instead of EACCESS
      bug :test_mv_symlink # no_error
      bug :test_remove_entry_secure # EPERM
      bug :test_remove_entry_secure_pathname # EPERM
      bug :test_remove_entry_secure_symlink # EPERM
      unsupported :test_cp_r_fifo
    end
  end

  class TestOpalFile
    bug :test_read_binary_utf8_file
  end

  class TestPathname
    # ::Find is missing, testing private methods, modifying Strings
    bug :test_atime
    bug :test_ctime
    bug :test_find
    bug :test_mtime
    bug :test_to_s
    unsupported :test_del_trailing_separator_131
    unsupported :test_del_trailing_separator_7323
    unsupported :test_destructive_update
    unsupported 'test_has_trailing_separator?_131'.to_sym
    unsupported 'test_has_trailing_separator?_7323'.to_sym
    unsupported :test_kernel_open
    unsupported :test_relative_path_from_casefold
    if ::Opal.JS[:platform].JS[:windows]
      unsupported :test_owned? # Process.geteuid is -1
    end
  end
end
