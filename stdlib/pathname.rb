# backtick_javascript: true

# inspired by ruby/ext/pathname

require 'corelib/comparable'
require 'tmpdir'
require 'fileutils'

# Portions from Author:: Tanaka Akira <akr@m17n.org>
class Pathname
  include Comparable

  SAME_PATHS = if File::FNM_SYSCASE.nonzero?
                 # Avoid #zero? here because #casecmp can return nil.
                 proc { |a, b| a.casecmp(b) == 0 }
               else
                 proc { |a, b| a == b }
               end

  if File::ALT_SEPARATOR
    SEPARATOR_LIST = "#{Regexp.quote File::ALT_SEPARATOR}#{Regexp.quote File::SEPARATOR}"
    SEPARATOR_PAT = /[#{SEPARATOR_LIST}]/
  else
    SEPARATOR_LIST = "#{Regexp.quote File::SEPARATOR}"
    SEPARATOR_PAT = /#{Regexp.quote File::SEPARATOR}/
  end

  `let absolute_path`
  if File.dirname('A:') == 'A:.' # DOSish drive letter
    `absolute_path = #{/\A(?:[A-Za-z]:|#{SEPARATOR_PAT})/o}`
  else
    `absolute_path = #{/\A#{SEPARATOR_PAT}/o}`
  end

  class << self
    def getwd
      # Returns the current working directory as a Pathname.
      new(::Dir.pwd)
    end

    def glob(*args, &block)
      # See Dir.glob. Returns or yields Pathname objects.
      if block_given?
        ::Dir.glob(*args) { |entry| block.call(new(entry)) }
      else
        ::Dir.glob(*args).map { |entry| new(entry) }
      end
    end

    def mktmpdir(&block)
      # Creates a tmp directory and wraps the returned path in a Pathname object. See Dir.mktmpdir
      if block_given?
        ::Dir.mktmpdir { |dir| block.call(new(dir)) }
      else
        new(::Dir.mktmpdir)
      end
    end

    alias pwd getwd
  end

  # helpers

  def chop_basename(path) # :nodoc:
    base = File.basename(path)
    # ruby uses /^#{SEPARATOR_PAT}?$/o but having issues with interpolation
    if Regexp.new("^#{Pathname::SEPARATOR_PAT.source}?$") =~ base
      return nil
    else
      return path[0, path.rindex(base)], base
    end
  end

  # actual methods

  def initialize(path)
    if Pathname === path
      @path = path.path.to_s
    elsif path.respond_to?(:to_path)
      @path = path.to_path
    elsif path.is_a?(String)
      @path = `Opal.str(path)`
    elsif path.nil?
      raise TypeError, 'no implicit conversion of nil into String'
    else
      raise TypeError, "no implicit conversion of #{path.class} into String"
    end
    raise ArgumentError if `self.path.endsWith("\0")`
  end

  attr_reader :path

  def +(other)
    # Appends a pathname fragment to self to produce a new Pathname object.
    other = Pathname.new(other) unless Pathname === other

    plus = ->(path1, path2) do
      prefix2 = path2
      index_list2 = []
      basename_list2 = []
      while (r2 = chop_basename(prefix2))
        prefix2, basename2 = r2
        index_list2.unshift prefix2.length
        basename_list2.unshift basename2
      end
      return path2 if prefix2 != ''
      prefix1 = path1
      while true
        while !basename_list2.empty? && basename_list2.first == '.'
          index_list2.shift
          basename_list2.shift
        end
        break unless (r1 = chop_basename(prefix1))
        prefix1, basename1 = r1
        next if basename1 == '.'
        if basename1 == '..' || basename_list2.empty? || basename_list2.first != '..'
          prefix1 += basename1
          break
        end
        index_list2.shift
        basename_list2.shift
      end
      r1 = chop_basename(prefix1)
      if !r1 && /#{SEPARATOR_PAT}/ =~ File.basename(prefix1)
        while !basename_list2.empty? && basename_list2.first == '..'
          index_list2.shift
          basename_list2.shift
        end
      end
      if !basename_list2.empty?
        suffix2 = path2[index_list2.first..-1]
        r1 ? File.join(prefix1, suffix2) : prefix1 + suffix2
      else
        r1 ? prefix1 : File.dirname(prefix1)
      end
    end

    Pathname.new(plus.call(@path, other.to_s))
  end

  alias / +

  def ==(other)
    return false unless Pathname === other
    other.path == @path
  end

  alias === ==

  alias eql? ==

  def <=>(other)
    return unless Pathname === other
    sp = @path
    op = other.path
    s = o = nil
    i = 0
    while `(s = sp[i]) && (o = op[i])`
      `s = '\0'` if `s == '/'`
      `o = '\0'` if `o == '/'`
      if `s != o`
        return `s < o` ? -1 : 1
      end
      i += 1
    end
    return 1 if `i < sp.length`
    return -1 if `i < op.length`
    0
  end

  undef =~

  def absolute?
    # Predicate method for testing whether a path is absolute.
    `absolute_path`.match? @path
  end

  def ascend
    # Iterates over and yields a new Pathname object for each element in the given path in ascending order.
    return to_enum(:ascend) unless block_given?
    path = @path
    yield self

    del_trailing_separator =-> (path) do
      if r = chop_basename(path)
        pre, basename = r
        pre + basename
      elsif /#{SEPARATOR_PAT}+\z/o =~ path
        $` + File.dirname(path)[/#{SEPARATOR_PAT}*\z/o]
      else
        path
      end
    end

    while r = chop_basename(path)
      path, = r
      break if path.empty?
      yield Pathname.new(del_trailing_separator.call(path))
    end
  end

  def atime
    # Returns the last access time for the file.
    ::File.atime(@path)
  end

  def basename(ext = nil)
    # Returns the last component of the path.
    Pathname.new(::File.basename(@path, ext))
  end

  def binread(length = nil, offset = nil)
    # Returns all the bytes from the file, or the first N if specified.
    ::File.binread(@path, length, offset)
  end

  def binwrite(string, offset = nil, **opts)
    # Writes contents to the file, opening it in binary mode.
    ::File.binwrite(@path, string, offset, **opts)
  end

  def birthtime
    # Returns the birth time for the file.
    ::File.birthtime(@path)
  end

  def blockdev?
    # See FileTest.blockdev?.
    ::File.blockdev?(@path)
  end

  def chardev?
    # See FileTest.chardev?.
    ::File.chardev?(@path)
  end

  def children(with_directory=true)
    # Returns the children of the directory (files and subdirectories, not recursive) as an array of Pathname objects.
    with_directory = false if @path == '.'
    result = []
    ::Dir.foreach(@path) do |e|
      next if e == '.' || e == '..'
      if with_directory
        result << self.class.new(::File.join(@path, e))
      else
        result << self.class.new(e)
      end
    end
    result
  end

  def chmod(mode)
    # Changes file permissions.
    ::File.chmod(mode, @path)
  end

  def chown(owner_int, group_int)
    # Change owner and group of the file.
    ::File.chown(owner_int, group_int, @path)
  end

  def cleanpath(consider_symlink=false)
    # Returns clean pathname of self with consecutive slashes and useless dots removed. The filesystem is not accessed.

    prepend_prefix = ->(prefix, relpath) do
      if relpath.empty?
        File.dirname(prefix)
      elsif /#{SEPARATOR_PAT}/o.match?(prefix)
        prefix = File.dirname(prefix)
        prefix = File.join(prefix, "") if File.basename(prefix + 'a') != 'a'
        prefix + relpath
      else
        prefix + relpath
      end
    end

    has_trailing_separator = ->(path) do
      if r = chop_basename(path)
        pre, basename = r
        pre.length + basename.length < path.length
      else
        false
      end
    end

    if consider_symlink
      path = @path
      names = []
      pre = path
      while r = chop_basename(pre)
        pre, base = r
        names.unshift base if base != '.'
      end
      pre = pre.tr(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      if /#{SEPARATOR_PAT}/o.match?(File.basename(pre))
        names.shift while names[0] == '..'
      end
      if names.empty?
        self.class.new(File.dirname(pre))
      else
        if names.last != '..' && File.basename(path) == '.'
          names << '.'
        end
        result = prepend_prefix.call(pre, File.join(*names))
        if /\A(?:\.|\.\.)\z/ !~ names.last && has_trailing_separator.call(path)
          self.class.new(add_trailing_separator(result))
        else
          self.class.new(result)
        end
      end
    else
      path = @path
      names = []
      pre = path
      while r = chop_basename(pre)
        pre, base = r
        case base
        when '.'
        when '..'
          names.unshift base
        else
          if names[0] == '..'
            names.shift
          else
            names.unshift base
          end
        end
      end
      pre = pre.tr(File::ALT_SEPARATOR, File::SEPARATOR) if File::ALT_SEPARATOR
      if /#{SEPARATOR_PAT}/o.match?(File.basename(pre))
        names.shift while names[0] == '..'
      end
      self.class.new(prepend_prefix.call(pre, File.join(*names)))
    end
  end

  def ctime
    # Returns the last change time, using directory information, not the file itself.
    ::File.ctime(@path)
  end

  def delete
    # Removes a file or directory, using File.unlink if self is a file, or Dir.unlink as necessary.
    begin
      ::Dir.unlink(@path)
    rescue ::Errno::ENOTDIR
      ::File.unlink(@path)
    end
    0
  end

  def descend
    # Iterates over and yields a new Pathname object for each element in the given path in descending order.
    return to_enum(:descend) unless block_given?
    vs = []
    ascend { |v| vs << v }
    vs.reverse_each { |v| yield v }
    nil
  end

  def directory?
    # See FileTest.directory?.
    ::File.directory?(@path)
  end

  def dirname
    # Returns all but the last component of the path.
    ::Pathname.new(::File.dirname(@path))
  end

  def each_child(with_directory=true, &block)
    # Iterates over the children of the directory (files and subdirectories, not recursive).
    children(with_directory).each(&block)
  end

  def each_entry(&block)
    # Iterates over the entries (files and subdirectories) in the directory, yielding a Pathname object for each entry.
    return enum_for(:each_entry) unless block_given?
    ::Dir.foreach(@path) { |entry| block.call(Pathname.new(entry)) }
  end

  def each_filename
    # Iterates over each component of the path.
    return to_enum(:each_filename) unless block_given?

    split_names = ->(path) do
      names = []
      while r = chop_basename(path)
        path, basename = r
        names.unshift basename
      end
      names
    end

    names = split_names.call(@path)
    names.each { |filename| yield filename }
    nil
  end

  def each_line(sep = $/, limit = nil, **opts, &block)
    # Iterates over each line in the file and yields a String object for each.
    ::File.foreach(@path, sep, limit, **opts, &block)
  end

  def empty?
    # Tests the file is empty.
    ::File.directory?(@path) ? ::Dir.empty?(@path) : ::File.empty?(@path)
  end

  def entries
    # Return the entries (files and subdirectories) in the directory, each as a Pathname object.
    ::Dir.entries(@path).map { |f| self.class.new(f) }
  end

  def executable?
    # See FileTest.executable?.
    ::File.executable?(@path)
  end

  def executable_real?
    # See FileTest.executable_real?.
    ::File.executable_real?(@path)
  end

  def exist?
    # See FileTest.exist?.
    ::File.exist?(@path)
  end

  def expand_path(basedir = nil)
    # Returns the absolute path for the file.
    ::Pathname.new(::File.expand_path(@path, basedir))
  end

  def extname
    # Returns the file’s extension.
    ::File.extname(@path)
  end

  def file?
    # See FileTest.file?.
    ::File.file?(@path)
  end

  def find
    # Iterates over the directory tree in a depth first manner,
    # yielding a Pathname for each file under “this” directory.

    raise ::NotImplementedError # we don't have ::Find yet

    # but here is the implementation anyways:
    # return to_enum(:find, ignore_error: ignore_error) unless block_given?
    # require 'find'
    # if @path == '.'
    #   ::Find.find(@path, ignore_error: ignore_error) {|f| yield self.class.new(f.delete_prefix('./')) }
    # else
    #   ::Find.find(@path, ignore_error: ignore_error) {|f| yield self.class.new(f) }
    # end
  end

  def fnmatch(pattern, flags = 0)
    # Return true if the receiver matches the given pattern.
    ::File.fnmatch(pattern, @path, flags)
  end

  alias fnmatch? fnmatch

  def ftype
    # Returns “type” of file (“file”, “directory”, etc).
    ::File.ftype(@path)
  end

  def glob(patterns, flags = nil, &block)
    # Returns or yields Pathname objects. See Dir.glob.
    path = @path
    if block_given?
      ::Dir.glob(patterns, base: @path, flags: flags) { |entry| block.call(Pathname.new(::File.join(path, entry))) }
    else
      ::Dir.glob(patterns, base: @path, flags: flags).map { |entry| Pathname.new(::File.join(path, entry)) }
    end
  end

  def grpowned?
    # See FileTest.grpowned?.
    ::File.grpowned?(@path)
  end

  def hash
    @path.hash
  end

  def inspect
    "#<#{self.class.name}:#{@path}>"
  end

  def join(*args)
    # Joins the given pathnames onto self to create a new Pathname object.
    # This is effectively the same as using Pathname#+ to append self and all arguments sequentially.
    return self if args.empty?
    result = args.pop
    result = Pathname.new(result) unless Pathname === result
    return result if result.absolute?
    args.reverse_each do |arg|
      arg = Pathname.new(arg) unless Pathname === arg
      result = arg + result
      return result if result.absolute?
    end
    self + result
  end

  def lchmod(mode)
    # Same as Pathname.chmod, but does not follow symbolic links.
    ::File.lchmod(mode, @path)
  end

  def lchown(owner, group)
    # Same as Pathname.chown, but does not follow symbolic links.
    ::File.lchown(owner, group, @path)
  end

  def lstat
    # See File.lstat.
    ::File.lstat(@path)
  end

  def lutime(atime, mtime)
    # Update the access and modification times of the file.
    ::File.lutime(atime, mtime, @path)
  end

  def make_link(old)
    # Creates a hard link at pathname. See File.link.
    ::File.link(old, @path)
  end

  def make_symlink(old)
    # Creates a symbolic link. See File.symlink.
    ::File.symlink(old, @path)
  end

  def mkdir(permissions = 0o775)
    # Create the referenced directory.
    ::Dir.mkdir(@path, permissions)
  end

  def mkpath(mode: nil)
    # Creates a full path, including any intermediate directories that don’t yet exist.
    # See FileUtils.mkpath and FileUtils.mkdir_p
    FileUtils.mkpath(@path, mode: mode)
    self
  end

  def mountpoint?
    # Returns true if self points to a mountpoint.
    begin
      stat1 = self.lstat
      stat2 = self.parent.lstat
      stat1.dev != stat2.dev || stat1.ino == stat2.ino
    rescue Errno::ENOENT
      false
    end
  end

  def mtime
    # Returns the last modified time of the file. See File.mtime.
    ::File.mtime(@path)
  end

  def open(mode = nil, perm = 0o666, **opts, &block)
    # Opens the file for reading or writing. See File.open.
    ::File.open(@path, mode, perm, **opts, &block)
  end

  def opendir(*opts, &block)
    # Opens the referenced directory. See Dir.open.
    ::Dir.open(@path, *opts, &block)
  end

  def owned?
    # See FileTest.owned?.
    ::File.owned?(@path)
  end

  def parent
    # Returns the parent directory. This is same as self + '..'.
    self + '..'
  end

  def pipe?
    # See FileTest.pipe?.
    ::File.pipe?(@path)
  end

  def read(length = nil, offset = 0, **opts)
    # Returns all data from the file, or the first N bytes if specified. See File.read.
    ::File.read(@path, length, offset, **opts)
  end

  def readable?
    # See FileTest.readable?.
    ::File.readable?(@path)
  end

  def readable_real?
    # See FileTest.readable_real?.
    ::File.readable_real?(@path)
  end

  def readlines(sep = $/, limit = nil, **opts)
    # Returns all the lines from the file. See File.readlines.
    ::File.readlines(@path, sep, limit, **opts)
  end

  def readlink
    # Read symbolic link. See File.readlink.
    Pathname.new(::File.readlink(@path))
  end

  def realdirpath(basedir = nil)
    # Returns the real (absolute) pathname of self in the actual filesystem.
    Pathname.new(::File.realdirpath(@path, basedir))
  end

  def realpath(basedir = nil)
    # Returns the real (absolute) pathname for self in the actual filesystem.
    Pathname.new(::File.realpath(@path, basedir))
  end

  def relative?
    !absolute?
  end

  def relative_path_from(base_directory)
    # Returns a relative path from the given base_directory to the receiver.
    base_directory = Pathname.new(base_directory) unless base_directory.is_a? Pathname
    dest_directory = cleanpath.to_s
    base_directory = base_directory.cleanpath.to_s
    dest_prefix = dest_directory
    dest_names = []
    while (r = chop_basename(dest_prefix))
      dest_prefix, basename = r
      dest_names.unshift basename if basename != '.'
    end
    base_prefix = base_directory
    base_names = []
    while (r = chop_basename(base_prefix))
      base_prefix, basename = r
      base_names.unshift basename if basename != '.'
    end
    unless SAME_PATHS[dest_prefix, base_prefix]
      raise ArgumentError, "different prefix: #{dest_prefix.inspect} and #{base_directory.inspect}"
    end
    while !dest_names.empty? &&
          !base_names.empty? &&
          SAME_PATHS[dest_names.first, base_names.first]
      dest_names.shift
      base_names.shift
    end
    if base_names.include? '..'
      raise ArgumentError, "base_directory has ..: #{base_directory.inspect}"
    end
    base_names.fill('..')
    relpath_names = base_names + dest_names
    if relpath_names.empty?
      Pathname.new('.')
    else
      Pathname.new(File.join(*relpath_names))
    end
  end

  def rename(to)
    # Rename the file. See File.rename.
    to = to.to_path if Pathname === to
    ::File.rename(@path, to)
  end

  def rmdir
    # Remove the referenced directory. See Dir.rmdir.
    ::Dir.rmdir(@path)
  end

  def rmtree(noop: nil, verbose: nil, secure: nil)
    # Recursively deletes a directory, including all directories beneath it. See FileUtils.rm_rf
    FileUtils.rm_rf(@path, noop: noop, verbose: verbose, secure: secure)
    self
  end

  def root?
    # Predicate method for root directories. Returns true if the pathname consists of consecutive slashes.
    chop_basename(@path) == nil && /#{SEPARATOR_PAT}/o.match?(@path)
  end

  def setgid?
    # See FileTest.setgid?.
    ::File.setgid?(@path)
  end

  def setuid?
    # See FileTest.setuid?.
    ::File.setuid?(@path)
  end

  def size
    # See FileTest.size.
    ::File.size(@path)
  end

  def size?
    # See FileTest.size?.
    ::File.size?(@path)
  end

  def socket?
    # See FileTest.socket?.
    ::File.socket?(@path)
  end

  def split
    # Returns the dirname and the basename in an Array.
    [dirname, basename]
  end

  def stat
    # Returns a File::Stat object. See File.stat.
    ::File.stat(@path)
  end

  def sticky?
    # See FileTest.sticky?.
    ::File.sticky?(@path)
  end

  def sub(*args, &block)
    # Return a pathname which is substituted by String#sub.
    str = @path.sub(*args, &block)
    Pathname.new(str)
  end

  def sub_ext(repl)
    # Return a pathname with repl added as a suffix to the basename.
    ext = extname
    str = ext ? `self.path.slice(0, self.path.length - ext.length)` : @path
    Pathname.new(str + repl)
  end

  def symlink?
    # See FileTest.symlink?.
    ::File.symlink?(@path)
  end

  def sysopen(mode = nil, perm = nil)
    # See IO.sysopen.
    ::IO.sysopen(@path, mode, perm)
  end

  def to_path
    `Opal.str(self.path)`
  end

  alias to_s to_path

  def truncate(length)
    # Truncates the file to length bytes. See File.truncate.
    ::File.truncate(@path, length)
  end

  alias unlink delete

  def utime(atime, mtime)
    # Update the access and modification times of the file. See File.utime.
    ::File.utime(atime, mtime, @path)
  end

  def world_readable?
    # See FileTest.world_readable?.
    ::File.world_readable?(@path)
  end

  def world_writable?
    # See FileTest.world_writable?.
    ::File.world_writable?(@path)
  end

  def writable?
    # See FileTest.writable?.
    ::File.writable?(@path)
  end

  def writable_real?
    # See FileTest.writable_real?.
    ::File.writable_real?(@path)
  end

  def write(data, offset = nil, **opts)
    # Writes contents to the file. See File.write.
    ::File.write(@path, data, offset, **opts)
  end

  def zero?
    # See FileTest.zero?.
    ::File.zero?(@path)
  end
end

module Kernel
  def Pathname(path)
    return path if Pathname === path
    Pathname.new(path)
  end
end
