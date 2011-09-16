
class File

  # Converts the given `file_name` into its absolute path. The current working
  # directory is used as the reference unless the `dir_string` is given, in
  # which case that is used.
  #
  # @param [String] file_name
  # @param [String] dir_string
  # @return [String]
  def self.expand_path(file_name, dir_string = nil)
    if dir_string
      `return Op.fs.expand_path(file_name, dir_string);`
    else
      `return Op.fs.expand_path(file_name);`
    end
  end

  # Returns a new string constructed by joining the given args with the default
  # file separator.
  #
  # @param [String] str
  # @return [String]
  def self.join(*str)
    `return Op.fs.join.apply(Op.fs, str);`
  end

  # Returns all the components of the given `file_name` except for the last
  # one.
  #
  # @param [String] file_name
  # @return [String]
  def self.dirname(file_name)
    `return Op.fs.dirname(file_name);`
  end

  # Returns the extension of the given filename.
  #
  # @param [String] file_name
  # @return [String]
  def self.extname(file_name)
    `return Op.fs.extname(file_name);`
  end

  # Returns the last path component of the given `file_name`. If a suffix is
  # given, and is present in the path, then it is removed. This is useful for
  # removing file extensions, for example.
  #
  # @param [String] file_name
  # @param [String] suffix
  # @return [String]
  def self.basename(file_name, suffix)
    `return Op.fs.basename(file_name, suffix);`
  end

  def self.exist?(path)
    `return Op.fs.exist_p(path);`
  end
end

