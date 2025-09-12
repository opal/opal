# backtick_javascript: true
# helpers: platform, str, glob_brace_expand, is_star_star_slash, mbinc, is_dirsep

class ::Dir
  include ::Enumerable

  class << self
    def [](*patterns, base: `undefined`, sort: true)
      # Calls Dir.glob with argument patterns and the values of keyword arguments base and sort;
      # returns the array of selected entry names.
      glob(*patterns, flags: nil, base: base, sort: sort)
    end

    if `$platform.chdir`
      def chdir(dir = nil)
        # Changes the current working directory.
        unless dir
          dir = ::ENV['HOME'] || ::ENV['LOGDIR']
          return 0 unless dir
        end
        dir = ::Opal.coerce_to!(dir, ::String, :to_path) rescue dir
        dir = ::Opal.coerce_to!(dir, ::String, :to_str)
        unless block_given?
          `$platform.chdir(#{dir}.toString())`
          return 0
        end
        cwd = pwd
        begin
          `$platform.chdir(#{dir}.toString())`
          yield dir
        ensure
          `$platform.chdir(#{cwd}.toString())`
        end
      end
    else
      alias chdir __not_implemented__
    end

    def children(dirpath, encoding: nil)
      # Returns an array of the entry names in the directory at dirpath except for '.' and '..';
      # sets the given encoding onto each returned entry name
      each_child(dirpath, encoding: encoding).to_a
    end

    if `$platform.dir_chroot`
      def chroot(dirpath)
        # Changes the root directory of the calling process to that specified in dirpath.
        # The new root directory is used for pathnames beginning with '/'.
        # The root directory is inherited by all children of the calling process.
        # Only a privileged process may call chroot.
        dirpath = ::Opal.coerce_to!(dirpath, ::String, :to_path)
        `$platform.dir_chroot(dirpath)`
        0
      end
    else
      alias chroot __not_implemented__
    end

    if `$platform.rmdir`
      def delete(dirpath)
        # Removes the directory at dirpath from the underlying file system.
        dirpath = ::Opal.coerce_to!(dirpath, ::String, :to_path)
        `$platform.rmdir(dirpath.toString())`
        0
      end
    else
      alias delete __not_implemented__
    end

    def each_child(dirpath, encoding: nil, &block)
      # Like Dir.foreach, except that entries '.' and '..' are not included.
      return enum_for(:each_child, dirpath, encoding: encoding) unless block_given?
      Dir.new(dirpath, encoding: encoding).each_child(&block)
      nil
    end

    def empty?(dirpath)
      # Returns whether dirpath specifies an empty directory.
      children(dirpath).empty?
    rescue Errno::ENOTDIR
      false
    end

    def entries(dirpath, encoding: nil)
      # Returns an array of the entry names in the directory at dirpath;
      # sets the given encoding onto each returned entry name.^
      foreach(dirpath, encoding: encoding).to_a
    end


    if `$platform.lstat`
      def exist?(dirpath)
        # Returns whether dirpath is a directory in the underlying file system.
        ::File.lstat(dirpath).directory?
      rescue
        false
      end
    else
      alias exist? __not_implemented__
    end

    if `$platform.dir_path`
      def fchdir(fd)
        # Changes the current working directory to the directory specified by the integer file descriptor fd.
        # When passing a file descriptor over a UNIX socket or to a child process, using fchdir instead of
        # chdir avoids the time-of-check to time-of-use vulnerability. With no block,
        # changes to the directory given by fd.
        chdir(`$platform.dir_path(fd)`)
      end

      def for_fd(fd)
        # Returns a new Dir object representing the directory specified by the given integer directory
        # file descriptor fd.
        new(`$platform.dir_path(fd)`)
      end
    else
      alias fchdir __not_implemented__
      alias for_fd __not_implemented__
    end

    def foreach(dirpath, encoding: nil, &block)
      # Calls the block with each entry name in the directory at dirpath;
      # sets the given encoding onto each passed entry_name.
      return enum_for(:foreach, dirpath, encoding: encoding) unless block_given?
      new(dirpath, encoding: encoding).each(&block)
      nil
    end

    def getwd
      # Returns the path to the current working directory.
      wd = `$platform.dir_wd()`
      wd = wd.gsub('\\', '/') if `$platform.windows`
      `$str(wd)`
    end

    if `$platform.stat && $platform.lstat`
      def glob(*patterns, flags: nil, base: `undefined`, sort: true, &block)
        # Forms an array entry_names of the entry names selected by the arguments.
        # Argument patterns is a string pattern or an array of string patterns;
        # note that these are not regexps.

        # This a more or less straightforward port of dir_s_glob and related functions from ruby/dir.c.
        base = if `base === undefined`
                 nil
               elsif base.nil?
                 getwd
               else
                 base = ::Opal.coerce_to!(base, ::String, :to_path)
                 base == '.' || base == '' ? getwd : base
               end
        flags = patterns.pop if patterns.size == 2 && patterns[1].is_a?(::Integer)
        flags = flags ? ::Opal.coerce_to!(flags, ::Integer, :to_int) : 0

        raise(ArgumentError, "expected true or false as sort: #{sort}") unless sort == true || sort == false

        period = (flags & ::File::FNM_DOTMATCH) != ::File::FNM_DOTMATCH # as used in #fnmatch
        escape = (flags & ::File::FNM_NOESCAPE) != ::File::FNM_NOESCAPE

        # some constant values which are specific to glob
        glob_verboseC = 1 << 24

        path_unknownC = -2
        path_noentC = -1
        path_existC = 0
        path_directoryC = 4
        path_regularC = 8
        path_symlinkC = 10

        plainC = 1
        alphaC = 2
        braceC = 3
        magicalC = 4
        recursiveC = 5
        match_allC = 6
        match_dirC = 7

        # just like in ruby/dir.c
        find_dirsep = ->(pat, pi) do
          op = nil
          while (c = `pat[pi]`)
            case c
            when '['
              op = true
            when ']'
              op = false
            when '{'
              op = true
            when '}'
              op = false
            when '/'
              return pi unless op
            when '\\'
              return pi if escape && !(c = `pat[pi++]`)
            when "\x00"
              raise(ArgumentError, 'nul-separated pattern')
            end
            pi = `$mbinc(pat, pi)`
          end
          pi
        end

        # just like in ruby/dir.c
        has_magic = ->(pat, pi, pe) do
          hasalpha = false
          hasmagical = false
          while pi < pe && (c = `pat[pi]`) && `c != '\x00'`
            case c
            when '{'
              return braceC
            when '*', '?', '['
              hasmagical = true
            when '\\'
              break if escape && (`pi++` >= pe)
            when '.'
              # nothing if `$platform.windows`
            when '~'
              hasalpha = true if `$platform.windows`
            else
              hasalpha = true if `$platform.windows || c.match(/[a-zA-Z]/)`
            end
            pi = `$mbinc(pat, pi)`
          end
          hasmagical ? magicalC : (hasalpha ? alphaC : plainC)
        end

        # just like in ruby/dir.c
        glob_make_pattern = ->(pat) do
          dirsep = recursive = false
          list = tail = tmp = nil
          pi = 0

          while `pat[pi]`
            if `$is_star_star_slash(pat, pi)`
              pi += 3
              pi += 1 while `pat[pi] == '/'`
              while `$is_star_star_slash(pat, pi)`
                pi += 3
                pi += 1 while `pat[pi] == '/'`
              end
              tmp = { str: nil, type: recursiveC }
              dirsep = true
              recursive = true
            else
              m = find_dirsep.(pat, pi)
              magic = has_magic.(pat, pi, m)
              non_magic = ::File::FNM_SYSCASE > 0 || `$platform.windows` ? plainC : alphaC
              if !(::File::FNM_SYSCASE > 0 || magic > non_magic) && !recursive && `pat[m]`
                while has_magic.(pat, m + 1, m2 = find_dirsep.(pat, m + 1)) <= non_magic && `pat[m2]`
                  m = m2
                end
              end
              tmp = { str: `pat.slice(pi, m)`,
                      type: magic > magicalC ? magicalC : (magic > non_magic ? magic : plainC) }
              if `pat[m]`
                dirsep = true
                pi = m + 1
              else
                dirsep = false
                pi = m
              end
            end

            if !list
              list = tail = tmp
            else
              tail = tail[:next] = tmp
            end
          end

          tmp = { str: nil, type: dirsep ? match_dirC : match_allC, next: nil }

          return tmp unless tail

          tail[:next] = tmp

          list
        end

        # just like in ruby/dir.c
        join_path_from_pattern = ->(pl) do
          path = nil
          str = nil
          while pl
            case pl[:type]
            when recursiveC
              str = '**'
            when match_dirC
              str = ''
            else
              str = pl[:str]
              unless str
                pl = pl[:next]
                next
              end
            end
            if !path
              path = str
            else
              path = path + '/' + str
            end
            pl = pl[:next]
          end
          path
        end

        # just like in ruby/dir.c
        join_path = ->(path, len, dirsep, name, namelen) do
          path = `len < path.length ? path.slice(0, len) : path`
          path += '/' if dirsep
          path += `namelen < name.length ? name.slice(0, namelen) : name`
        end

        glob_helper = nil

        # just like in ruby/dir.c
        push_caller = ->(path, args) do
          list = glob_make_pattern.(path)
          return nil unless list
          glob_helper.(args[:path], args[:baselen], args[:namelen], args[:dirsep],
                       args[:pathtype], [list], args[:flags], args[:arg]
                      )
        end

        # unlike in ruby/dir.c, this is used together with File.lstat and File.stat
        # instead of having do_lstat or do_stat
        detect_pathtype = ->(st) do
          if !st
            path_noentC
          elsif st.directory?
            path_directoryC
          elsif st.symlink?
            path_symlinkC
          elsif st.file?
            path_regularC
          else
            path_existC
          end
        end

        # just like in ruby/dir.c
        glob_open_dir = ->(dirp, flgs) do
          entries = dirp.to_a
          return entries if flgs % ::File::FNM_GLOB_NOSORT == ::File::FNM_GLOB_NOSORT
          entries.sort
        end

        # just like in ruby/dir.c
        remove_backslashes = ->(name) do
          `name.replaceAll(/\\(.)/g, '$1')`
        end

        # the literally label extracted from glob_helper, because we dont have goto
        literally = ->(path, baselen, namelen, dirsep, list, flgs, arg) do
          status = false
          pathlen = baselen + namelen

          copy_list = []
          list.each do |pl|
            copy_list.push(pl[:type] <= alphaC ? pl : nil)
          end

          cur = 0
          while cur < `copy_list.length`
            pl = copy_list[cur]
            if pl
              name = pl[:str]
              name = remove_backslashes.(name) if escape
              new_list = []
              new_list << pl[:next]

              cur2 = cur + 1
              while cur2 < `copy_list.length`
                pl2 = copy_list[cur2]
                if pl2 && ::File.fnmatch(pl2[:str], name, flgs)
                  new_list << pl2[:next]
                  cur2 = 0
                end
                cur2 += 1
              end

              buf = join_path.(path, pathlen, dirsep, name, `name.length`)

              # this is probably correctly done by js engines on windows, so we dont need to,
              # we couldn't do it anyway, unless we would have access to getattrlist on windows
              # if `$platform.windows`
              #   if pl[:type] == alphaC
              #     buf = replace_real_basename.(buf, (pathlen + dirsep ? 1 : 0), flgs)
              #     break unless buf
              #   end
              # end

              status = glob_helper.(buf, baselen, namelen + `buf.length` - pathlen, true,
                                    path_unknownC, new_list, flgs, arg
                                   )

              break if status
            end
            cur += 1
          end

          status
        end

        # just like in ruby/dir.c
        dirent_match = ->(pat, name, flgs) do
          ::File.fnmatch(pat, name, flgs)
        end

        # just like in ruby/dir.c
        dirent_match_brace = ->(pat, arg) { dirent_match.(pat, arg[:name], arg[:flags]) }

        # just like in ruby/dir.c
        glob_helper = ->(path, baselen, namelen, dirsep, pathtype, list, flgs, arg) do
          brace = magical = match_all = match_dir = plain = recursive = status = false
          pathlen = baselen + namelen

          list.each do |pl|
            if pl[:type] == recursiveC
              recursive = true
              pl = pl[:next]
            end

            case pl[:type]
            when plainC
              plain = true
            when alphaC
              if `$platform.windows`
                plain = true
              else
                magical = 1
              end
            when braceC
              str = pl[:str]
              brace = true if !recursive || `str.indexOf('/') != -1`
            when magicalC
              magical = 2
            when match_allC
              match_all = true
            when match_dirC
              match_dir = true
            when recursiveC
              raise 'BUG! continuous RECURSIVEs'
            end
          end

          if brace
            brace_path = join_path_from_pattern.(list[0])
            return nil unless brace_path
            args = {
              path: path,
              baselen: baselen,
              namelen: namelen,
              dirsep: dirsep,
              pathtype: pathtype,
              flags: flgs,
              arg: arg
            }
            return `$glob_brace_expand(brace_path, push_caller, escape, args)`
          end

          if `path.length > 0`
            if match_all && pathtype == path_unknownC
              st = ::File.lstat(path) rescue nil
              pathtype = detect_pathtype.(st)
            end

            if match_dir && pathtype == path_unknownC || pathtype == path_symlinkC
              st = ::File.stat(path) rescue nil
              pathtype = detect_pathtype.(st)
            end

            if match_all && pathtype > path_noentC
              subpath = `path.slice(baselen + (baselen > 0 && path[baselen] == '/' ? 1 : 0))`
              if `subpath.length > 0`
                status = arg[:match_func].(subpath, arg)
                return status if status
              end
            end

            if match_dir && pathtype == path_directoryC
              seplen = `baselen > 0 && path[baselen] == '/' ? 1 : 0`
              subpath = `path.slice(baselen + seplen)`
              tmp = join_path.(subpath, namelen - seplen, dirsep, '', 0)
              status = arg[:match_func].(tmp, arg)
              return status if status
            end
          end

          return false if pathtype == path_noentC

          if magical || recursive

            # this would be the call to do_opendir
            begin
              dirp = new(path == '' ? '.' : path)
            rescue ::Errno::ENOENT, ::Errno::ENOTDIR
              dirp = nil
            rescue ::Errno::EACCES
              return literally.(path, baselen, namelen, dirsep, list, flgs, arg) if ::File::FNM_SYSCASE > 0 && !recursive
              dirp = nil
            rescue => e
              return err_func.(path, e)
            end

            return status unless dirp

            begin
              glob_entries = glob_open_dir.(dirp, flgs)

              skipdot = (flgs & ::File::FNM_GLOB_SKIPDOT) == ::File::FNM_GLOB_SKIPDOT
              flgs |= ::File::FNM_GLOB_SKIPDOT

              glob_entries.each do |name|
                new_pathtype = path_unknownC
                dotfile = 0
                namlen = `name.length`

                if `name[0] == '.'`
                  dotfile += 1
                  if namlen == 1
                    # unless DOTMATCH, skip current directories not to recurse infinitely
                    next if recursive && period
                    next if skipdot
                    dotfile += 1
                    new_pathtype = path_directoryC
                  elsif namlen == 2 && `name[1] == '.'`
                    # always skip parent directories not to recurse infinitely
                    next
                  end
                end

                buf = join_path.(path, pathlen, dirsep, name, namlen)
                n = dirsep ? 1 : 0

                st = ::File.lstat(buf)
                new_pathtype = detect_pathtype.(st)

                if recursive && dotfile < (period ? 1 : 2) && new_pathtype == path_unknownC
                  new_pathtype = path_noentC
                end

                new_list = []

                list.each do |pl|
                  if pl[:type] == recursiveC
                    if path_existC <= new_pathtype && new_pathtype < path_symlinkC
                      new_list << pl if dotfile < (period ? 1 : 2)
                    end
                    pl = pl[:next]
                  end

                  case pl[:type]
                  when braceC
                    args = { name: name, flags: flgs }
                    new_list << pl[:next] if `$glob_brace_expand(pl.get('str'), dirent_match_brace, escape, args)`
                  when alphaC, plainC, magicalC
                    new_list << pl[:next] if dirent_match.(pl[:str], name, flgs)
                  end
                end

                status = glob_helper.(buf, baselen, `pathlen + n - baselen + namlen`, true,
                                      new_pathtype, new_list, flgs, arg
                                    )

                break if status
              end
            ensure
              dirp.close
            end

          elsif plain
            # literally:
            status = literally.(path, baselen, namelen, dirsep, list, flgs, arg)
          end

          status
        end

        # just like in ruby/file.c
        rb_path_skip_prefix = ->(path) do
          if `path[0]?.match(/[a-zA-Z]/) && path[1] == ':'`
            2
          elsif `$is_dirsep(path[0]) && $is_dirsep(path[1])`
            i = 1
            while `$is_dirsep(path[i+1])`
              i += 1
            end
            i
          else
            0
          end
        end

        # just like in ruby/dir.c
        # this lambda is passed on to Opal.glob_brace_expand, hence using the call signature with arg
        ruby_glob0 = ->(pat, arg) do
          base = arg[:base]

          baselen = 0
          root = start = 0
          dirsep = false

          return `$glob_brace_expand(pat, ruby_glob0, escape, arg)` if `pat[root] == '{'`

          flgs = arg[:flags] | ::File::FNM_SYSCASE

          root = rb_path_skip_prefix.(`pat.slice(root)`) if `$platform.windows`

          root += 1 if `pat[root] == '/'`

          n = root
          buf = if n == 0 && base
                  dirsep = true
                  baselen = n = `base.length`
                  base
                else
                  `pat.slice(start, start + n)`
                end

          list = glob_make_pattern.(`root > 0 ? pat.slice(root) : pat`)

          return nil unless list

          glob_helper.(buf, baselen, `n - baselen`, dirsep, path_unknownC, [list], flgs, arg)
        end

        # just like in ruby/dir.c
        push_pattern = ->(path, arg) do
          arg[:res] << path
          false # indicating no error
        end

        # just like in ruby/dir.c
        rb_glob_error = ->(path, exc) do
          $stderr.puts "glob warning #{path}" if exc.is_a?(::Errno::EACCES)
          raise exc
        end

        res = []

        patterns.each do |pattern|
          if pattern.is_a?(::Array)
            res.concat(glob(*pattern, flags: flags, base: base))
          else
            begin
              pattern = ::Opal.coerce_to!(pattern, ::String, :to_path)
              arg = {
                base: base,
                flags: flags | glob_verboseC,
                res: res,
                match_func: push_pattern,
                err_func: rb_glob_error
              }
              ruby_glob0.(pattern, arg)
            rescue ::Errno::ENOENT, ::Errno::ENOTDIR
              return []
            rescue ::Errno::EACCES
              return nil
            end
          end
        end

        return res unless block_given?
        res.each(&block)
        nil
      end
    else
      alias glob __not_implemented__
    end

    def home(user_name = nil)
      # Returns the home directory path of the user specified with user_name if it is not nil, or the current login user
      if user_name
        # once we have a platform that provides the required apis, this best be move to drivers
        if `$platform.windows`
          if `!user_name.match(/['"()]/)`
            h = ::Kernel.send('`', "powershell.exe -Command \"(Get-CimInstance Win32_UserProfile -Filter \"\"\"SID = '$((Get-LocalUser #{user_name}).Sid)'\"\"\").LocalPath\" 2>&1").lines[0].chomp
            return `$str(#{h.gsub('\\', '/')})` unless h.empty? || h.start_with?('Get-')
          end
        else
          # On macOS we need to check /etc/passwd, which contains some system internal users but not regular users
          # and the directory service, which contains regular users but not all system internal users.
          # We need to check /etc/passwd first, because otherwise there may be an error.
          if ::File.exist?('/etc/passwd')
            ::File.open('/etc/passwd', 'r') do |passwd_file|
              passwd_file.each_line do |entry|
                next if entry.start_with?('#')
                name_s, _passwd, _uid_s, _gid_s, _gecos, h, _shell = entry.split(':')
                return h if name_s == user_name
              end
            end
          end
          if `$platform.macos`
            if `!user_name.match(/[\.\/\\]/)`
              # Users may have multiple home directories registered in the directory service on macOS, take the first.
              h_lines = ::Kernel.send('`', "dscl . read /Users/#{user_name} NFSHomeDirectory 2>&1").lines
              info, h = h_lines[0].chomp.split(':')
              if `!info.match(/error/i)`
                # multiple directories may come in one line or in multiple lines, in any case, take the first
                h = h.sub(/^\s+/, '').sub(/\s$/, '')
                h, _ = h.split(' ') if h_lines.size == 1
                return `$str(h)`
              end
            end
          end
        end
        raise(::ArgumentError, "user #{user_name} not found")
      else
        h = ::ENV['HOME']
        if `$platform.windows`
          h ||= ENV['USERPROFILE']
          h = ENV['HOMEDRIVE'] + ENV['HOMEPATH'] if !h && ENV['HOMEDRIVE'] && ENV['HOMEPATH']
        end
        h ||= `$platform.dir_home ? $platform.dir_home() : '.'` || '.'
        h = h.gsub('\\', '/') if `$platform.windows`
        `$str(h)`
      end
    end

    if `$platform.mkdir`
      def mkdir(path, permissions = 0o775)
        # Creates a directory in the underlying file system at dirpath with the given permissions; returns zero.
        path = ::Opal.coerce_to!(path, ::String, :to_path)
        permissions = ::Opal.coerce_to!(permissions, ::Integer, :to_int)
        `$platform.mkdir(path.toString(), permissions)`
        0
      end
    else
      alias mkdir __not_implemented__
    end

    def open(dirpath, encoding: nil)
      dir = new(dirpath, encoding: encoding)
      return dir unless block_given?
      begin
        yield dir
      ensure
        dir.close
      end
    end

    alias pwd getwd

    alias rmdir delete

    alias unlink delete
  end

  %x{
    function check_open(io) {
      if (io.closed) #{raise IOError, 'closed stream'};
    }
  }

  if `$platform.dir_open`
    def initialize(dirpath, encoding: nil)
      # Returns a new Dir object for the directory at dirpath.
      dirpath = ::Opal.coerce_to!(dirpath, ::String, :to_path)
      @fileno = `$platform.dir_open(dirpath.toString())`
      @closed = false
      @path = dirpath
      @pos = 0
      @encoding = if encoding && encoding.is_a?(::Encoding)
                    encoding
                  elsif encoding
                    ::Encoding.find(encoding)
                  elsif ::Encoding.default_internal != ::Encoding::UTF_8
                    ::Encoding.default_internal
                  end
    end
  else
    alias initialize __not_implemented__
  end

  if `$platform.chdir`
    def chdir
      # Changes the current working directory to self.
      `$platform.chdir(self.path.toString())`
    end
  else
    alias chdir __not_implemented__
  end

  def children
    # Returns an array of the entry names in self except for '.' and '..'.
    each_child.to_a
  end

  if `$platform.dir_close`
    def close
      # Closes the stream in self, if it is open, and returns nil; ignored if self is already closed.
      `$platform.dir_close(self.fileno)` unless @closed
      @closed = true
      nil
    end
  else
    alias close __not_implemented__
  end

  def each
    # Calls the block with each entry name in self.
    `check_open(self)`
    return enum_for :each unless block_given?
    while (name = read)
      yield name
    end
    self
  end

  def each_child
    # Calls the block with each entry name in self except '.' and '..'.
    `check_open(self)`
    return enum_for :each_child unless block_given?
    while (name = read)
      next if name == '.' || name == '..'
      yield name
    end
    self
  end

  # Returns the file descriptor used in dir.
  attr_reader :fileno

  def inspect
    # Returns a string description of self. Dir.new('example').inspect # => "#<Dir:example>"
    "#<#{self.class.name}:#{@path}>"
  end

  # Returns the dirpath string that was used to create self (or nil if created by method Dir.for_fd).
  attr_reader :path

  def pos
    # Returns the current position of self
    `check_open(self)`
    @pos
  end

  def pos=(position)
    # Sets the position in self and returns position.
    # The value of position should have been returned from an earlier call to tell;
    # if not, the return values from subsequent calls to read are unspecified.
    rewind
    while @pos < position
      break unless read
    end
    @pos
  end

  if `$platform.dir_next`
    def read
      # Reads and returns the next entry name from self; returns nil if at end-of-stream.
      `check_open(self)`
      @pos += 1
      res = `$platform.dir_next(self.fileno)`
      return nil unless res
      @encoding ? `$str(res, self.encoding)` : `res`
    end
  else
    alias read __not_implemented__
  end

  if `$platform.dir_rewind`
    def rewind
      # Sets the position in self to zero.
      `check_open(self)`
      `$platform.dir_rewind(self.fileno)`
      @pos = 0
      self
    end
  else
    alias rewind __not_implemented__
  end

  def seek(position)
    rewind
    while @pos < position
      break unless read
    end
    self
  end

  alias tell pos
  alias to_path path
end
