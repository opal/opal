
class Dir
  # OPAL_FS simply points to the main opal.fs namespace. This might be the
  # default fs in the browser, or may be overriden within the opal build tools
  # when running on top of the gem runtime. Both are compatible interfaces.
  `var OPAL_FS = $rb.opal.fs;`

  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.getwd
    `return OPAL_FS.cwd;`
  end

  # Returns a string that is the current working directory for this process.
  #
  # @return [String]
  def self.pwd
    `return OPAL_FS.cwd;`
  end

  def self.[](*a)
    `return OPAL_FS.glob.apply(OPAL_FS, a);`
  end
end

