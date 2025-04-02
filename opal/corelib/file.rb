# helpers: platform, truthy, str, is_star_star_slash, mbinc, mbclen
# backtick_javascript: true

class ::File < ::IO
  # for constants see corelib/file/constants

  windows_root_rx = %r{^[a-zA-Z]:(?:\\|\/)}

  %x{
    function check_writable(io) {
      if (io.closed === "write" || io.closed === "both" ) #{raise IOError, 'not opened for writing'};
    }

    function coerce_to_path(path) {
      if ($truthy(#{`path`.respond_to?(:to_path)})) path = path.$to_path();
      return #{::Opal.coerce_to!(`path`, ::String, :to_str)};
    }

    // Return a RegExp compatible char class
    function $sep_chars() {
      if (#{ALT_SEPARATOR} === nil) {
        return Opal.escape_regexp(#{SEPARATOR});
      } else {
        return Opal.escape_regexp(#{SEPARATOR + ALT_SEPARATOR});
      }
    }

    function time_at_ms(ms) {
      let s = Math.floor(ms / 1000);
      return #{::Time.at(`s`, `ms - s * 1000`, :millisecond)};
    }
  }

  class Stat
    include ::Comparable

    def initialize(path, alt_stat = nil)
      # Create a File::Stat object for the given file name (raising an exception if the file doesn’t exist).
      # The alt_stat param is not official Ruby, but used internally for fstat/lstat.
      if alt_stat
        @path = path # may be nil
        @stat = alt_stat
      else
        @path = `coerce_to_path(path)`
        @stat = `$platform.file_stat(self.path)`
      end
      raise ::Errno::ENOENT unless @stat
    end

    def <=>(other)
      # Compares File::Stat objects by comparing their respective modification times.
      self.mtime <=> other.mtime
    end

    def atime
      # Returns the last access time for this file as an object of class Time.
      `time_at_ms(self.stat.atimeMs)`
    end

    def birthtime
      # Returns the birth time for stat.
      # If the platform doesn’t have birthtime, raises NotImplementedError.
      `time_at_ms(self.stat.birthtimeMs)`
    end

    def blksize
      # Returns the native file system’s block size.
      # Will return nil on platforms that don’t support this information.
      `self.stat.blksize`
    end

    def blockdev?
      # Returns true if the file is a block device, false if it isn’t or
      # if the operating system doesn’t support this feature.
      `self.stat.isBlockDevice()`
    end

    def blocks
      # Returns the number of native file system blocks allocated for this file,
      # or nil if the operating system doesn’t support this feature.
      `self.stat.blocks`
    end

    def chardev?
      # Returns true if the file is a character device, false if it isn’t or
      # if the operating system doesn’t support this feature.
      `self.stat.isCharacterDevice()`
    end

    def ctime
      # Returns the change time for stat (that is, the time directory information
      # about the file was changed, not the file itself).
      `time_at_ms(self.stat.ctimeMs)`
    end

    def dev
      # Returns an integer representing the device on which stat resides.
      `self.stat.dev`
    end

    def dev_major
      # Returns the major part of File_Stat#dev or nil.
      ((dev >> 8) & 0xfff) | ((dev >> 32) & ~0xfff)
    end

    def dev_minor
      # Returns the minor part of File_Stat#dev or nil.
      (dev & 0xff) | ((dev >> 12) & ~0xff)
    end

    def directory?
      # Returns true if stat is a directory, false otherwise.
      `self.stat.isDirectory()`
    end

    def executable?
      # Returns true if stat is executable or if the operating system doesn’t
      # distinguish executable files from nonexecutable files.
      # The tests are made using the effective owner of the process.
      (owned? && 0o100 == (mode & 0o100)) ||
      (grpowned? && 0o10 == (mode & 0o10)) ||
      (0o1 == (mode & 0o1))
    end

    def executable_real?
      # Same as executable?, but tests using the real owner of the process.
      (uid == ::Process.uid && 0o100 == (mode & 0o100)) ||
      (gid == ::Process.gid && 0o10 == (mode & 0o10)) ||
      (0o1 == (mode & 0o1))
    end

    def file?
      # Returns true if stat is a regular file (not a device file, pipe, socket, etc.).
      `self.stat?.isFile()`
    end

    def ftype
      # Identifies the type of stat. The return string is one of:
      return 'file' if file?
      return 'link' if symlink?
      return 'directory' if directory?
      return 'characterSpecial' if chardev?
      return 'blockSpecial' if blockdev?
      return 'socket' if socket?
      return 'fifo' if pipe?
      'unknown'
    end

    def gid
      `self.stat.gid`
    end

    def grpowned?
      # Returns true if the effective group id of the process is the same as
      # the group id of stat. On Windows, returns false.
      gid == ::Process.egid || Process.groups.include?(gid)
    end

    def ino
      # Returns the inode number for stat.
      `self.stat.ino`
    end

    def inspect
      # Produce a nicely formatted description of stat.
      "#<File::Stat dev=#{dev.to_s(16)}, ino=#{ino}, mode=#{mode.to_s(16)}," +
      " nlink=#{nlink}, uid=#{uid}, gid=#{gid}, rdev=#{rdev.to_s(16)}, size=#{size}, blksize=#{blksize}," +
      " blocks=#{blocks}, atime=#{atime}, mtime=#{mtime}, ctime=#{ctime}, birthtime=#{birthtime}"
    end

    def mode
      # Returns an integer representing the permission bits of stat.
      # The meaning of the bits is platform dependent.
      `self.stat.mode`
    end

    def mtime
      # Returns the modification time of stat.
      `time_at_ms(self.stat.mtimeMs)`
    end

    def nlink
      `self.stat.nlink`
    end

    def owned?
      # Returns true if the effective user id of the process is the same as the owner of stat.
      uid == ::Process.euid
    end

    def pipe?
      # Returns true if the operating system supports pipes and stat is a pipe; false otherwise.
      `self.stat.isFIFO()`
    end

    def rdev
      # Returns an integer representing the device type on which stat resides.
      # Returns nil if the operating system doesn’t support this feature.
      `self.stat.rdev`
    end

    def rdev_major
      # Returns the major part of File_Stat#rdev or nil
      ((rdev >> 8) & 0xfff) | ((rdev >> 32) & ~0xfff)
    end

    def rdev_minor
      # Returns the minor part of File_Stat#rdev or nil.
      (rdev & 0xff) | ((rdev >> 12) & ~0xff)
    end

    def readable?
      # Returns true if stat is readable by the effective user id of this process.
      (owned? && 0o400 == (mode & 0o400)) ||
      (grpowned? && 0o40 == (mode & 0o40)) ||
      (0o4 == (mode & 0o4))
    end

    def readable_real?
      # Returns true if stat is readable by the real user id of this process.
      (uid == ::Process.uid && 0o400 == (mode & 0o400)) ||
      (gid == ::Process.gid && 0o40 == (mode & 0o40)) ||
      (0o4 == (mode & 0o4))
    end

    def setgid?
      # Returns true if stat has the set-group-id permission bit set, false if
      # it doesn’t or if the operating system doesn’t support this feature.
      1024 == (mode & 0o2000)
    end

    def setuid?
      # Returns true if stat has the set-user-id permission bit set, false if
      # it doesn’t or if the operating system doesn’t support this feature.
      2048 == (mode & 0o4000)
    end

    def size
      # Returns the size of stat in bytes.
      `self.stat?.size`
    end

    def size?
      # Returns nil if stat is a zero-length file, the size of the file otherwise.
      zero? ? nil : size
    end

    def socket?
      # Returns true if stat is a socket, false if it isn’t or
      # if the operating system doesn’t support this feature.
      `self.stat.isSocket()`
    end

    def sticky?
      # Returns true if stat has its sticky bit set, false if it doesn’t or
      # if the operating system doesn’t support this feature.
      512 == (mode & 0o1000)
    end

    def symlink?
      # Returns true if stat is a symbolic link, false if it isn’t
      # or if the operating system doesn’t support this feature.
      %x{
        if (typeof self.stat.isSymbolicLink === "function") return self.stat.isSymbolicLink();
        else return false;
      }
    end

    def uid
      # Returns the numeric user id of the owner of stat.
      `self.stat.uid`
    end

    def world_readable?
      # If stat is readable by others, returns an integer representing the file permission bits of stat.
      # Returns nil otherwise.
      4 == (mode & 0o4) ? mode : nil
    end

    def world_writable?
      # If stat is writable by others, returns an integer representing the file permission bits of stat.
      # Returns nil otherwise.
      2 == (mode & 0o2) ? mode : nil
    end

    def writable?
      # Returns true if stat is writable by the effective user id of this process.
      (owned? && 0o200 == (mode & 0o200)) ||
      (grpowned? && 0o20 == (mode & 0o20)) ||
      (0o2 == mode & 0o2)
    end

    def writable_real?
      # Returns true if stat is writable by the real user id of this process.
      (uid == ::Process.uid && 0o200 == (mode & 0o200)) ||
      (gid == ::Process.gid && 0o20 == (mode & 0o20)) ||
      (0o2 == mode & 0o2)
    end

    def zero?
      `self.stat.size === 0`
    end
  end

  class << self
    def absolute_path(path, basedir = nil)
      # Converts a pathname to an absolute pathname.
      path = `coerce_to_path(path)`
      basedir = basedir ? `coerce_to_path(basedir)` : ::Dir.pwd
      sep = SEPARATOR
      new_parts = []
      path_abs = `path.slice(0, sep.length) == sep`
      path_abs = true if !path_abs && `$platform.windows` && `windows_root_rx.test(path)`
      basedir_abs = `basedir.slice(0, sep.length) == sep`
      basedir_abs = true if !basedir_abs && `$platform.windows` && `windows_root_rx.test(basedir)`

      if path_abs
        parts       = `path.split(sep)`
        leading_sep = `windows_root_rx.test(path) ? '' : #{path.sub(/^(#{sep}+).*$/, '\1')}`
        abs         = true
      else
        parts       = `basedir.split(sep)`
        parts.concat(`path.split(sep)`)
        leading_sep = `windows_root_rx.test(basedir) ? '' : #{basedir.sub(/^(#{sep}+).*$/, '\1')}`
        abs         = basedir_abs
      end
      %x{
        var part;
        for (var i = 0, ii = parts.length; i < ii; i++) {
          part = parts[i];

          if (
            (part === nil) ||
            (part == ''  && ((new_parts.length === 0) || abs)) ||
            (part == '.' && ((new_parts.length === 0) || abs))
          ) {
            continue;
          }
          if (part == '..') {
            new_parts.pop();
          } else {
            new_parts.push(part);
          }
        }

        if (!abs && parts[0] != '.') {
          #{new_parts.unshift '.'}
        }
      }

      new_path = new_parts.join(sep)
      new_path = leading_sep + new_path if abs
      new_path
    end

    def absolute_path?(path)
      # Returns true if file_name is an absolute path, and false otherwise.
      `$platform.file_is_absolute_path(path)`
    end

    def atime(file_name)
      # Returns the last access time for the named file as a Time object.
      stat(file_name).atime
    end

    def basename(name, suffix = nil)
      # Returns the last component of the filename given in file_name
      # (after first stripping trailing separators), which can be formed
      # using both File::SEPARATOR and File::ALT_SEPARATOR as the separator
      # when File::ALT_SEPARATOR is not nil. If suffix is given and present
      # at the end of file_name, it is removed.
      # If suffix is “.*”, any extension will be removed.
      sep_chars = `$sep_chars()`
      name = `coerce_to_path(name)`
      %x{
        if (name.length == 0) {
          return name;
        }

        if (suffix !== nil) {
          suffix = #{::Opal.coerce_to!(suffix, ::String, :to_str)}
        } else {
          suffix = null;
        }

        name = name.replace(new RegExp(#{"(.)[#{sep_chars}]*$"}), '$1');
        name = name.replace(new RegExp(#{"^(?:.*[#{sep_chars}])?([^#{sep_chars}]+)$"}), '$1');

        if (suffix === ".*") {
          name = name.replace(/\.[^\.]+$/, '');
        } else if(suffix !== null) {
          suffix = Opal.escape_regexp(suffix);
          name = name.replace(new RegExp(#{"#{suffix}$"}), '');
        }

        return name;
      }
    end

    def birthtime(file_name)
      # Returns the birth time for the named file. file_name can be an IO object.
      stat(file_name).birthtime
    end

    def blockdev?(file_name)
      # Returns true if filepath points to a block device, false otherwise.
      stat(file_name).blockdev?
    end

    def chardev?(file_name)
      # Returns true if filepath points to a character device, false otherwise.
      stat(file_name).chardev?
    end

    def chmod(mode_int, *file_names)
      # Changes permission bits on the named file(s) to the bit pattern represented by mode_int.
      mode_int = ::Opal.coerce_to!(mode_int, ::Integer, :to_int) unless mode_int.is_a?(::Integer)
      raise(RangeError, "mode_int out of range") if mode_int < 0 || mode_int > 4294967295
      file_names.each do |file_name|
        file_name = `coerce_to_path(file_name)`
        `$platform.file_chmod(file_name, mode_int)`
      end
      file_names.size
    end

    def chown(owner_int, group_int, *file_names)
      # Changes the owner and group of the named file(s) to the given numeric owner and group id’s.
      owner_int = ::Opal.coerce_to!(owner_int, ::Integer, :to_int) if owner_int
      group_int = ::Opal.coerce_to!(group_int, ::Integer, :to_int) if group_int
      file_names.each do |file_name|
        file_name = `coerce_to_path(file_name)`
        if owner_int.nil? || group_int.nil?
          s = stat(file_name)
          oi = owner_int || s.uid
          gi = group_int || s.gid
        else
          oi = owner_int
          gi = group_int
        end
        `$platform.file_chown(file_name, oi, gi)`
      end
      file_names.size
    end

    def ctime(file_name)
      # Returns the change time for the named file (the time at which directory information about
      # the file was changed, not the file itself).
      stat(file_name).ctime
    end

    def delete(*file_names)
      # Deletes the named files, returning the number of names passed as arguments.
      file_names.each do |file_name|
        file_name = `coerce_to_path(file_name)`
        `$platform.file_unlink(file_name)`
      end
      file_names.size
    end

    def directory?(file_name)
      # With string object given, returns true if path is a string path leading to a directory,
      # or to a symbolic link to a directory; false otherwise.
      stat(file_name).directory?
    rescue Errno::ENOENT
      false
    end

    def dirname(file_name, level = 1)
      # Returns all components of the filename given in file_name except the last one
      # (after first stripping trailing separators).
      return file_name if level == 0
      ::Kernel.raise ::ArgumentError, "level can't be negative" if level < 0

      sep_chars = `$sep_chars()`
      path = `coerce_to_path(file_name)`
      %x{
        var absolute = path.match(new RegExp(#{"^[#{sep_chars}]"})), out;

        path = path.replace(new RegExp(#{"[#{sep_chars}]+$"}), ''); // remove trailing separators
        path = path.replace(new RegExp(#{"[^#{sep_chars}]+$"}), ''); // remove trailing basename
        path = path.replace(new RegExp(#{"[#{sep_chars}]+$"}), ''); // remove final trailing separators

        if (path === '') {
          out = absolute ? '/' : '.';
        }
        else {
          out = path;
        }

        if (level == 1) {
          return out;
        }
        else {
          return #{dirname(`out`, level - 1)}
        }
      }
    end

    def empty?(file_name)
      # Returns true if the named file exists and has a zero size.
      stat(file_name).zero?
    rescue Errno::ENOENT
      false
    end

    def executable?(file_name)
      # Returns true if the named file is executable by the effective user and group id of this process.
      stat(file_name).executable?
    rescue Errno::ENOENT
      false
    end

    def executable_real?(file_name)
      # Returns true if the named file is executable by the real user and group id of this process.
      stat(file_name).executable_real?
    rescue Errno::ENOENT
      false
    end

    def exist?(file_name)
      # Return true if the named file exists.
      stat(file_name)
      true
    rescue TypeError => e
      raise e
    rescue
      false
    end

    def expand_path(path, basedir = nil)
      # Converts a pathname to an absolute pathname. Relative paths are referenced from the current
      # working directory of the process unless dir_string is given, in which case it will be used
      # as the starting point. The given pathname may start with a “~”, which expands to the process
      # owner’s home directory (the environment variable HOME must be set correctly).
      # “~user” expands to the named user’s home directory.
      sep = SEPARATOR
      sep_chars = `$sep_chars()`
      if `path[0] === '~' || (basedir && basedir[0] === '~')`
        home = Dir.home
        ::Kernel.raise(::ArgumentError, "couldn't find HOME environment -- expanding `~'") unless home
        leading_sep = `windows_root_rx.test(home) ? '' : #{home.sub(/^([#{sep_chars}]+).*$/, '\1')}`
        ::Kernel.raise(::ArgumentError, 'non-absolute home') unless home.start_with?(leading_sep)

        home            += sep
        home_path_regexp = /^\~(?:#{sep}|$)/
        path             = path.sub(home_path_regexp, home)
        basedir          = basedir.sub(home_path_regexp, home) if basedir
      end
      absolute_path(path, basedir)
    end

    def extname(path)
      # Returns the extension (the portion of file name in path starting from the last period).
      `path = coerce_to_path(path)`
      filename = basename(path)
      str = if filename.empty?
              ''
            else
              last_dot_idx = filename[1..-1].rindex('.')
              # extension name must contain at least one character .(something)
              last_dot_idx.nil? || last_dot_idx + 1 == filename.length - 1 ? '' : filename[(last_dot_idx + 1)..-1]
            end
      `$str(str)`
    end

    def file?(file_name)
      # Returns true if the named file exists and is a regular file.
      # file can be an IO object.
      stat(file_name).file?
    rescue Errno::ENOENT
      false
    end

    %x{
      function e_peek(et) {
        try { return et.$peek(); } catch { return nil; }
      }
      function e_next(et, cnt) {
        try {
          let ch, i = 0;
          while (cnt > i++) { ch = et.$next(); }
          return ch;
        } catch {
          return nil;
        }
      }
      function is_end(pathname, str, idx) {
        return !str[idx] || (pathname && str[idx] == '/');
      }
      function mbeql(str1, idx1, str2, idx2, len) {
        if (str1[idx1] != str2[idx2]) return false;
        if (len == 2 && str1[idx1+1] && str2[idx2+1] && str1[idx1+1] != str2[idx2+1]) return false;
        return true;
      }
      function unescape(escape, str, idx) {
        return (escape && str[idx] == '\\') ? idx + 1 : idx;
      }
    }

    def fnmatch(pattern, string, flags = 0)
      # Returns true if path matches against pattern. The pattern is not a regular expression;
      # instead it follows rules similar to shell filename globbing.

      # This is a straightforward port from ruby/dir.c, kinda sort of.

      pattern = ::Opal.coerce_to!(pattern, ::String, :to_str)
      string = `coerce_to_path(string)`
      flags = ::Opal.coerce_to!(flags, ::Integer, :to_int)
      period = (flags & ::File::FNM_DOTMATCH) != ::File::FNM_DOTMATCH
      pathname = (flags & ::File::FNM_PATHNAME) == ::File::FNM_PATHNAME
      extglob = (flags & ::File::FNM_EXTGLOB) == ::File::FNM_EXTGLOB
      escape = (flags & ::File::FNM_NOESCAPE) != ::File::FNM_NOESCAPE

      p = 0
      s = 0

      # Just like in ruby/dir.c.
      fnmatch_helper = ->(pat) do
        nocase = (flags & ::File::FNM_CASEFOLD) == ::File::FNM_CASEFOLD

        # Just like in ruby/dir.c.
        # And because its only used by fnmatch_helper, its embedded in it here.
        bracket = ->(pi) do
          return nil if `!pat[pi]`
          r1 = 0
          r2 = 0
          ok = false
          noot = false
          if `pat[pi] == '!'` || `pat[pi] == '^'`
            noot = true
            pi += 1
          end

          while `pat[pi] != ']'`
            t1 = pi
            t1 += 1 if escape && `pat[t1] == '\\'`
            return nil if `!pat[t1]`
            pi = t1 + `(r1 = $mbclen(pat, t1))`
            return nil if `pi >= pat.length`
            if `pat[pi] == '-'` && `pat[pi+1] != ']'`
              t2 = pi + 1
              t2 += 1 if escape && `pat[t2] == '\\'`
              return nil if `!pat[t2]`
              pi = t2 + `(r2 = $mbclen(pat, t2))`
              next if ok
              if `mbeql(pat, t1, string, s, r1)` || `mbeql(pat, t2, string, s, r2)`
                ok = true
                next
              end
              c1 = `string.codePointAt(s)`
              c2 = `pat.codePointAt(t1)`
              if (nocase)
                c1 = `String.fromCodePoint(c1).toUpperCase().codePointAt(0)`
                c2 = `String.fromCodePoint(c2).toUpperCase().codePointAt(0)`
              end
              next if c1 < c2
              c2 = `pat.codePointAt(t2)`
              if (nocase)
                c2 = `String.fromCodePoint(c2).toUpperCase().codePointAt(0)`
              end
              next if c1 > c2
            else
              next if ok
              if `mbeql(pat, t1, string, s, r1)`
                ok = true
                next
              end
              next if !nocase
              c1 = `String.fromCodePoint(string.codePointAt(s)).toUpperCase().codePointAt(0)`
              c2 = `String.fromCodePoint(pat.codePointAt(p)).toUpperCase().codePointAt(0)`
              next if c1 != c2
            end
            ok = true
          end
          ok == noot ? nil : pi+1
        end

        ptmp = nil
        stmp = nil
        r = nil

        return false if period && `string[s] == '.'` && `pat[unescape(escape, pat, p)] != '.'`

        failed = ->() do
          if ptmp && stmp
            p = ptmp
            stmp = `$mbinc(string, stmp)`
            s = stmp
            return false
          end
          true
        end

        while true
          if `pat[p]`
            case `pat[p]`
            when '*'
              p += 1
              p += 1 while `pat[p] == '*'`
              if `is_end(pathname, pat, unescape(escape, pat, p))`
                p = `unescape(escape, pat, p)`
                return true
              end
              return false if `is_end(pathname, string, s)`
              ptmp = p
              stmp = s
              next

            when '?'
              return false if `is_end(pathname, string, s)`
              p += 1
              s = `$mbinc(string, s)`
              next

            when '['
              return false if `is_end(pathname, string, s)`
              if (t = bracket.(p + 1)) != nil
                p = t
                s = `$mbinc(string, s)`
                next
              end
              return false if failed.call
              next
            end
          end

          p = `unescape(escape, pat, p)`
          if `is_end(pathname, string, s)`
            return `is_end(pathname, pat, p)` ? true : false
          end
          if `is_end(pathname, pat, p)`
            return false if failed.call
            next
          end
          r = `$mbclen(pat, p)`
          if r == 0
            return false if failed.call
            next
          end
          if `mbeql(pat, p, string, s, r)`
            p += r
            s += r
            next
          end
          if !nocase
            return false if failed.call
            next
          end
          c1 = `String.fromCodePoint(string.codePointAt(s)).toUpperCase().codePointAt(0)`
          c2 = `String.fromCodePoint(pat.codePointAt(p)).toUpperCase().codePointAt(0)`
          if c1 != c2
            return false if failed.call
            next
          end
          p += r
          s = `$mbinc(string, s)`
          next
        end
      end

      # In ruby/dir.c this would be the fnmatch() function.
      fnmatch_internal = -> (pat, _arg) do
        ptmp = nil
        stmp = nil

        if pathname
          while true
            if `$is_star_star_slash(pat, p)`
              p += 3
              p += 3 while `$is_star_star_slash(pat, p)`
              ptmp = p
              stmp = s
            end
            if fnmatch_helper.(pat)
              while (sc = `string[s]`) && sc != '/'
                s = `$mbinc(string, s)`
              end
              if `pat[p]` && `string[s]`
                p += 1
                s += 1
                next
              end
              return true if !`pat[p]` && !`string[s]`
            end
            if ptmp && stmp && !(period && `string[stmp]` == '.')
              while (sc = `string[stmp]`) && sc != '/'
                stmp = `$mbinc(string, stmp)`
              end
              if `string[stmp]`
                p = ptmp
                stmp += 1
                s = stmp
                next
              end
            end
            return false
          end
        end
        fnmatch_helper.(pat)
      end

      if extglob
        ::Opal.glob_brace_expand(pattern, fnmatch_internal, escape, nil)
      else
        fnmatch_internal.(pattern, nil)
      end
    end

    alias fnmatch? fnmatch

    def ftype(file_name)
      # Identifies the type of the named file.
      lstat(file_name).ftype
    end

    def grpowned?(file_name)
      # Returns true if the named file exists and the effective group id of
      # the calling process is the owner of the file.
      stat(file_name).grpowned?
    rescue Errno::ENOENT
      false
    end

    def identical?(file_1, file_2)
      # Returns true if the named files are identical.
      stat_1 = lstat(file_1)
      if stat_1.symlink?
        file_1 = readlink(file_1)
        stat_1 = stat(file_1)
      end
      stat_2 = lstat(file_2)
      if stat_2.symlink?
        file_2 = readlink(file_2)
        stat_2 = stat(file_2)
      end
      return true if stat_1.ino == stat_2.ino
      false
    rescue Errno::ENOENT
      false
    end

    def join(*paths)
      # Returns a new string formed by joining the strings using "/".
      return '' if paths.empty?
      enc = nil
      sep = SEPARATOR
      paths = paths.flatten.map! do |path|
        path = `coerce_to_path(path)`
        raise(::ArgumentError, 'string contains null byte') if path.include?("\x00")
        enc = path.encoding unless enc
        if ALT_SEPARATOR # Windows
          if sep == SEPARATOR && path.include?(ALT_SEPARATOR)
            sep = ALT_SEPARATOR
          elsif path.include?(SEPARATOR)
            sep = SEPARATOR
          end
        end
        path
      end
      if ALT_SEPARATOR # Windows
        if sep == ALT_SEPARATOR
          paths.map! do |path|
            # Oh my ...
            path.sub(/\/+$/, '\\').sub(/\A(\w:)\//, "\\1\\").sub(/\A\/\//, '\\\\').sub(/\A\//, '\\')
          end
        else
          paths.map! do |path|
            # Sigh ...
            path.sub(/\\+$/, '/').sub(/\A(\w:)\\/, "\\1/").sub(/\A\\\\/, '//').sub(/\A\\/, '/')
          end
        end
      end
      result = `$str('', enc)`
      paths.each_with_index do |item, index|
        item = item.sub(/#{sep}+$/, '/') if item.end_with?(sep)
        if index != 0
          if result.end_with?(sep)
            item = item[1..] if item.start_with?(sep)
          elsif !item.start_with?(sep)
            result += '/'
          end
        end
        result += item
      end
      result
    end

    def lchmod(mode_int, *file_names)
      # Equivalent to File::chmod, but does not follow symbolic links
      # (so it will change the permissions associated with the link,
      # not the file referenced by the link).
      mode_int = ::Opal.coerce_to!(mode_int, ::Integer, :to_int) unless mode_int.is_a?(::Integer)
      raise(RangeError, "mode_int out of range") if mode_int < 0 || mode_int > 4294967295
      file_names.each do |file_name|
        file_name = `coerce_to_path(file_name)`
        `$platform.file_lchmod(file_name, mode_int)`
      end
      file_names.size
    end

    def lchown(owner_int, group_int, *file_names)
      # Equivalent to File::chown, but does not follow symbolic links
      # (so it will change the owner associated with the link,
      # not the file referenced by the link).
    end

    def link(path, new_path)
      # Creates a new name for an existing file using a hard link.
      # Will not overwrite new_name if it already exists
      # (raising a subclass of SystemCallError).
      path = `coerce_to_path(path)`
      new_path = `coerce_to_path(new_path)`
      `$platform.file_link(path, new_path)`
      0
    end

    def lstat(file_name)
      # Like File::stat, but does not follow the last symbolic link;
      # instead, returns a File::Stat object for the link itself.
      file_name = `coerce_to_path(file_name)`
      Stat.new(file_name, `$platform.file_lstat(file_name)`)
    end

    def lutime(atime, mtime, *file_names)
      # Sets the access and modification times of each named file to the first two arguments.
      # If a file is a symlink, this method acts upon the link itself as opposed to its referent
      file_names.each do |file_name|
        file_name = `coerce_to_path(file_name)`
        `$platform.file_lutime(file_name, atime, mtime)`
      end
      file_names.size
    end

    def mkfifo(file_name, mode = nil)
      # Creates a FIFO special file with name file_name. mode specifies the FIFO’s permissions.
      # It is modified by the process’s umask in the usual way: the permissions of the
      # created file are (mode & ~umask).
      file_name = `coerce_to_path(file_name)`
      mode = 0o666 & ~File.umask unless mode
      status = `$platform.file_mkfifo(file_name, mode)`
      raise(::Errno::ENOENT, "No such file or directory #{file_name}") if status == 1
      0
    end

    def mtime(file_name)
      # Returns the modification time for the named file as a Time object.
      stat(file_name).mtime
    end

    def open(path, mode = nil, perm = 0o666, **opts)
      # Creates a new File object, via File.new with the given arguments.
      file = new(path, mode, perm, **opts)
      return file unless block_given?
      begin
        yield(file)
      ensure
        begin
          file.close
        rescue ::IOError => e
          raise e unless e.message == 'closed stream'
        end
      end
    end

    def owned?(file_name)
      # Returns true if the named file exists and the effective used id
      # of the calling process is the owner of the file.
      stat(file_name).owned?
    rescue ::Errno::ENOENT
      false
    end

    def path(path)
      # Returns the string representation of the path
      `coerce_to_path(path)`
    end

    def pipe?(file_name)
      # Returns true if filepath points to a pipe, false otherwise.
      stat(file_name).pipe?
    rescue ::Errno::ENOENT
      false
    end

    def readable?(file_name)
      # Returns true if the named file is readable by the effective user
      # and group id of this process.
      file_name = `coerce_to_path(file_name)`
      stat(file_name).readable?
    rescue
      false
    end

    def readable_real?(file_name)
      # Returns true if the named file is readable by the effective user
      # and group id of this process.
      file_name = `coerce_to_path(file_name)`
      stat(file_name).readable_real?
    rescue
      false
    end

    def readlink(link_name)
      # Returns the name of the file referenced by the given link.
      # Not available on all platforms.
      link_name = `coerce_to_path(link_name)`
      `$platform.file_readlink(link_name)`
    end

    def realdirpath(pathname, dir_string = nil)
      # Returns the real (absolute) pathname of pathname in the actual filesystem.
      # The real pathname doesn’t contain symlinks or useless dots.
      pathname = `coerce_to_path(pathname)`
      pathname = join(dir_string, pathname) if dir_string
      begin
        `$platform.file_realpath(pathname, #{::File::SEPARATOR})`
      rescue ::Errno::ENOENT
        pathname = readlink(pathname) if symlink?(pathname)
        dirname, file = split(pathname)
        dirname = `$platform.file_realpath(dirname, #{::File::SEPARATOR})` # may correctly raise ENOENT again
        return join(dirname, file)
      end
    end

    def realpath(pathname, dir_string = nil)
      # Returns the real (absolute) pathname of pathname in the actual filesystem
      # not containing symlinks or useless dots. If dir_string is given, it is used
      # as a base directory for interpreting relative pathname instead of the current directory.
      # All components of the pathname must exist when this method is called.
      pathname = `coerce_to_path(pathname)`
      pathname = join(dir_string, pathname) if dir_string
      result = `$platform.file_realpath(pathname, #{::File::SEPARATOR})`
      result
    end

    def rename(old_name, new_name)
      # Renames the given file to the new name. Raises a SystemCallError if the file cannot be renamed.
      old_name = ::Opal.coerce_to!(old_name, ::String, :to_str)
      new_name = ::Opal.coerce_to!(new_name, ::String, :to_str)
      `$platform.file_rename(old_name, new_name)`
      0
    end

    def setgid?(file_name)
      # Returns true if the named file has the setgid bit set.
      stat(file_name).setgid?
    rescue ::Errno::ENOENT
      false
    end

    def setuid?(file_name)
      # Returns true if the named file has the setuid bit set.
      stat(file_name).setuid?
    rescue ::Errno::ENOENT
      false
    end

    def size(file_name)
      # Returns the size of file_name.
      file_name = if file_name.respond_to?(:to_io)
                    file_name.to_io.path
                  else
                    `coerce_to_path(file_name)`
                  end
      stat(file_name).size
    end

    def size?(file_name)
      # Returns nil if file_name doesn’t exist or has zero size, the size of the file otherwise.
      file_name = if file_name.respond_to?(:to_io)
                    file_name.to_io.path
                  else
                    `coerce_to_path(file_name)`
                  end
      stat(file_name).size?
    rescue ::Errno::ENOENT
      nil
    end

    def socket?(file_name)
      # Returns true if filepath points to a socket, false otherwise.
      stat(file_name).socket?
    rescue ::Errno::ENOENT
      false
    end

    def split(path)
      # Splits the given string into a directory and a file component and returns them in a two-element array.
      path = `coerce_to_path(path)`
      return ['.', ''] if path.empty?
      if path.include?(SEPARATOR)
        parts = path.split(SEPARATOR)
        sep = SEPARATOR
      elsif ALT_SEPARATOR && path.include?(ALT_SEPARATOR)
        parts = path.split(ALT_SEPARATOR)
        sep = ALT_SEPARATOR
      else
        return ['.', path]
      end
      file = parts.pop
      [parts.join(sep), file]
    end

    def stat(path)
      # Returns a File::Stat object for the file at filepath (see File::Stat)
      Stat.new(path)
    end

    def sticky?(file_name)
      # Returns true if the named file has the sticky bit set.
      stat(file_name).sticky?
    rescue ::Errno::ENOENT
      false
    end

    def symlink(path, new_path)
      # Creates a symbolic link called new_name for the existing file old_name.
      path = `coerce_to_path(path)`
      new_path = `coerce_to_path(new_path)`
      `$platform.file_symlink(path, new_path)`
      0
    end

    def symlink?(file_name)
      # Returns true if filepath points to a symbolic link, false otherwise.
      lstat(file_name).symlink?
    rescue
      false
    end

    def truncate(file_name, integer)
      # Truncates the file file_name to be at most integer bytes long.
      file_name = `coerce_to_path(file_name)`
      integer = ::Opal.coerce_to!(integer, ::Integer, :to_int)
      raise(::Errno::EINVAL, 'integer must be >= 0') if integer < 0
      `$platform.file_truncate(file_name, integer)`
      0
    end

    def umask(integer = nil)
      # Returns the current umask value for this process. If the optional argument is given,
      # set the umask to that value and return the previous value.
      if integer
        integer = ::Opal.coerce_to!(integer, ::Integer, :to_int)
        if integer < 0 || integer > 4294967295
          raise(::RangeError,
                "The value of \"mask\" is out of range. It must be >= 0 && <= 4294967295. Received #{integer}")
        end
        `$platform.proc_set_umask(integer)`
      else
        `$platform.proc_get_umask()`
      end
    end

    alias unlink delete

    def utime(atime, mtime, *file_names)
      # Sets the access and modification times of each named file to the first two arguments.
      # If a file is a symlink, this method acts upon its referent rather than the link itself.
      if atime.nil? || mtime.nil?
        t = Time.now
        atime ||= t
        mtime ||= t
      end
      file_names.each do |file_name|
        file_name = ::Opal.coerce_to!(file_name, ::String, :to_path) unless file_name.is_a?(String)
        `$platform.file_utimes(file_name, atime, mtime)`
      end
      file_names.size
    end

    def world_readable?(file_name)
      # If file_name is readable by others, returns an integer representing the file permission bits of file_name.
      # Returns nil otherwise.
      stat(file_name).world_readable?
    rescue Errno::ENOENT
      nil
    end

    def world_writable?(file_name)
      # If stat is writable by others, returns an integer representing the file permission bits of stat.
      # Returns nil otherwise.
      stat(file_name).world_writable?
    rescue Errno::ENOENT
      nil
    end

    def writable?(file_name)
      # Returns true if the named file is writable by the effective user and group id of this process.
      stat(file_name).writable?
    rescue Errno::ENOENT
      false
    end

    def writable_real?(file_name)
      # Returns true if the named file is writable by the real user and group id of this process.
      stat(file_name).writable_real?
    rescue Errno::ENOENT
      false
    end

    alias zero? empty?
  end

  def initialize(path, mode = nil, perm = nil, **opts)
    # Opens the file at the given path according to the given mode;
    # creates and returns a new File object for that file.
    if mode.is_a?(Hash)
      opts = mode
      mode = nil
    end

    ag_mode = mode
    mode = nil
    flags = 0
    binary = false
    ext_enc = int_enc = nil

    [ag_mode, opts[:mode]].each do |m|
      if m
        raise(ArgumentError, 'mode given multiple times') if mode
        m = ::Opal.coerce_to!(m, ::String, :to_str) rescue m
        if m.is_a?(::String)
          m, ext_enc, int_enc = m.split(':') if m.include?(':')
          raise(ArgumentError, 'mode is a empty string') if m.empty?
          unless m.match?(/\Aw[bt]{0,1}[x]{0,1}[+]{0,1}\Z/) || m.match?(/\A[ra]([bt]{0,1}[+]{0,1}|[+]{0,1}[bt]{0,1})\Z/)
            raise(::ArgumentError, "invalid access mode #{m}")
          end
          flags |= `Opal.mode_to_flags(m)`
          mode = m
        else
          flags |= ::Opal.coerce_to!(m, ::Integer, :to_int)
        end
      end
    end

    flags |= ::Opal.coerce_to!(opts[:flags], ::Integer, :to_int) if opts.key?(:flags)
    opts[:flags] = flags
    opts[:mode] = mode
    opts[:external_encoding] = ext_enc if ext_enc
    opts[:internal_encoding] = int_enc if int_enc

    if !path.is_a?(::Integer)
      path = `coerce_to_path(path)`
      opts[:path] = path
      perm ||= 0o666
      begin
        fd = `$platform.io_open_path(path, flags, perm)`
      rescue ::Errno::EPERM
        raise ::Errno::EACCES
      end
    else
      fd = path
    end
    super(fd, nil, **opts)
  end

  def atime
    # Returns the last access time (a Time object) for file, or epoch if file has not been accessed.
    stat.atime
  end

  def birthtime
    # Returns the birth time for file.
    stat.birthtime
  end

  def chmod(mode_int)
    # Changes permission bits on file to the bit pattern represented by mode_int.
    mode_int = ::Opal.coerce_to!(mode_int, ::Integer, :to_int)
    raise(RangeError, "mode_int out of range") if mode_int < 0 || mode_int > 4294967295
    `$platform.file_fchmod(self.fd, mode_int)`
    0
  end

  def chown(owner_int, group_int)
    # Changes the owner and group of file to the given numeric owner and group id’s.
    # Only a process with superuser privileges may change the owner of a file.
    # The current owner of a file may change the file’s group to any group to which the owner belongs.
    # A nil or -1 owner or group id is ignored. Follows symbolic links.
    owner_int = ::Opal.coerce_to!(owner_int, ::Integer, :to_int) if owner_int
    group_int = ::Opal.coerce_to!(group_int, ::Integer, :to_int) if group_int
    if owner_int.nil? || group_int.nil?
      s = stat
      owner_int = owner_int || s.uid
      group_int = group_int || s.gid
    end
    `$platform.file_fchown(self.fd, owner_int, group_int)`
    0
  end

  def ctime
    # Returns the change time for file (that is,
    # the time directory information about the file was changed, not the file itself).
    stat.ctime
  end

  def flock(locking_constant)
    # Locks or unlocks file self according to the given locking_constant,
    # a bitwise OR of the values in the table below.
    `$platform.file_flock(self.fs, locking_constant)`
  end

  def lstat
    # Like File#stat, but does not follow the last symbolic link; instead,
    # returns a File::Stat object for the link itself
    self.class.lstat(@path)
  end

  def mtime
    # Returns the modification time for file.
    stat.mtime
  end

  def size
    # Returns the size of file in bytes.
    stat.size
  end

  def truncate(integer)
    # Truncates file to at most integer bytes. The file must be opened for writing.
    `check_writable(self)`
    integer = ::Opal.coerce_to!(integer, ::Integer, :to_int)
    raise(::Errno::EINVAL, 'integer must be >= 0') if integer < 0
    `$platform.file_ftruncate(self.fd, integer)`
    0
  end
end

require 'corelib/file/constants'

IO.include ::File::Constants
