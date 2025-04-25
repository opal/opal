module ::FileTest
  class << self
    def blockdev?(file_name)
      # Returns true if filepath points to a block device, false otherwise.
      ::File.blockdev?(file_name)
    end

    def chardev?(file_name)
      # Returns true if filepath points to a character device, false otherwise.
      ::File.chardev?(file_name)
    end

    def directory?(file_name)
      # With string object given, returns true if path is a string path leading to a directory,
      # or to a symbolic link to a directory; false otherwise.
      ::File.directory?(file_name)
    end

    def empty?(file_name)
      # Returns true if the named file exists and has a zero size.
      ::File.zero?(file_name)
    end

    def executable?(file_name)
      # Returns true if the named file is executable by the effective user and group id of this process.
      ::File.executable?(file_name)
    end

    def executable_real?(file_name)
      # Returns true if the named file is executable by the real user and group id of this process.
      ::File.executable_real?(file_name)
    end

    def exist?(file_name)
      # Return true if the named file exists.
      ::File.exist?(file_name)
    end

    def file?(file_name)
      # Returns true if the named file exists and is a regular file.
      # file can be an IO object.
      ::File.file?(file_name)
    end

    def grpowned?(file_name)
      # Returns true if the named file exists and the effective group id of
      # the calling process is the owner of the file.
      ::File.grpowned?(file_name)
    end

    def identical?(file1, file2)
      # Returns true if the named files are identical.
      ::File.identical?(file1, file2)
    end

    def owned?(file_name)
      # Returns true if the named file exists and the effective used id
      # of the calling process is the owner of the file.
      ::File.owned?(file_name)
    end

    def pipe?(file_name)
      # Returns true if filepath points to a pipe, false otherwise.
      ::File.pipe?(file_name)
    end

    def readable?(file_name)
      # Returns true if the named file is readable by the effective user
      # and group id of this process.
      ::File.readable?(file_name)
    end

    def readable_real?(file_name)
      # Returns true if the named file is readable by the effective user
      # and group id of this process.
      ::File.readable_real?(file_name)
    end

    def setgid?(file_name)
      # Returns true if the named file has the setgid bit set.
      ::File.setgid?(file_name)
    end

    def setuid?(file_name)
      # Returns true if the named file has the setuid bit set.
      ::File.setuid?(file_name)
    end

    def size(file_name)
      # Returns the size of file_name.
      ::File.size(file_name)
    end

    def size?(file_name)
      # Returns nil if file_name doesn’t exist or has zero size, the size of the file otherwise.
      ::File.size?(file_name)
    end

    def socket?(file_name)
      # Returns true if filepath points to a socket, false otherwise.
      ::File.socket?(file_name)
    end

    def sticky?(file_name)
      # Returns true if the named file has the sticky bit set.
      ::File.sticky?(file_name)
    end

    def symlink?(file_name)
      # Returns true if filepath points to a symbolic link, false otherwise.
      ::File.symlink?(file_name)
    end

    def world_readable?(file_name)
      # If file_name is readable by others, returns an integer representing the file permission bits of file_name.
      # Returns nil otherwise.
      ::File.world_readable?(file_name)
    end

    def world_writable?(file_name)
      # If stat is writable by others, returns an integer representing the file permission bits of stat.
      # Returns nil otherwise.
      ::File.world_writable?(file_name)
    end

    def writable?(file_name)
      # Returns true if the named file is writable by the effective user and group id of this process.
      ::File.writable?(file_name)
    end

    def writable_real?(file_name)
      # Returns true if the named file is writable by the real user and group id of this process.
      ::File.writable_real?(file_name)
    end

    alias zero? empty?
  end
end
