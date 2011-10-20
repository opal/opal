`var file_system = VM.opal.fs;`

class File
  # Converts the given `path` into its absolute path. The current working
  # directory is used as the reference unless the `dir_string` is given, in
  # which case that is used.
  #
  # @param [String] path
  # @param [String] dir_string
  # @return [String]
  def self.expand_path (path, dir_string = nil)
    if dir_string
      `file_system.expand_path(path, dir_string)`
    else
      `file_system.expand_path(path)`
    end
  end

  # Returns a new string constructed by joining the given args with the default
  # file separator.
  #
  # @param [String] paths
  # @return [String]
  def self.join (*paths)
    `file_system.join.apply(file_system, paths)`
  end

  # Returns all the components of the given `path` except for the last
  # one.
  #
  # @param [String] path
  # @return [String]
  def self.dirname (path)
    `file_system.dirname(path)`
  end

  # Returns the extension of the given filename.
  #
  # @param [String] path
  # @return [String]
  def self.extname (path)
    `file_system.extname(path)`
  end

  # Returns the last path component of the given `path`. If a suffix is
  # given, and is present in the path, then it is removed. This is useful for
  # removing file extensions, for example.
  #
  # @param [String] path
  # @param [String] suffix
  # @return [String]
  def self.basename (path, suffix)
    `file_system.basename(path, suffix)`
  end

  def self.exist? (path)
    `file_system.exist_p(path)`
  end
end
