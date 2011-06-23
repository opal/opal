
class File
  # Use either the browser fs namespace or overriden gem interface.
  `var OPAL_FS = $rb.opal.fs;`

  # Converts the given `file_name` into its absolute path. The current working
  # directory is used as the reference unless the `dir_string` is given, in
  # which case that is used.
  #
  # @param [String] file_name
  # @param [String] dir_string
  # @return [String]
  def self.expand_path(file_name, dir_string = nil)
    if dir_string
      `return OPAL_FS.expand_path(file_name, dir_string);`
    else
      `return OPAL_FS.expand_path(file_name);`
    end
  end

  # Returns a new string constructed by joining the given args with the default
  # file separator.
  #
  # @param [String] str
  # @return [String]
  def self.join(*str)
    `return OPAL_FS.join.apply(OPAL_FS, str);`
  end

  # Returns all the components of the given `file_name` except for the last
  # one.
  #
  # @param [String] file_name
  # @return [String]
  def self.dirname(file_name)
    `return OPAL_FS.dirname(file_name);`
  end

  # Returns the extension of the given filename.
  #
  # @param [String] file_name
  # @return [String]
  def self.extname(file_name)
    `return OPAL_FS.extname(file_name);`
  end

  # Returns the last path component of the given `file_name`. If a suffix is
  # given, and is present in the path, then it is removed. This is useful for
  # removing file extensions, for example.
  #
  # @param [String] file_name
  # @param [String] suffix
  # @return [String]
  def self.basename(file_name, suffix)
    `return OPAL_FS.basename(file_name, suffix);`
  end

  def self.exist?(path)
    `return OPAL_FS.exist_p(path) ? Qtrue : Qfalse;`
  end
end

