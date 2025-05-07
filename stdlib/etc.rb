# helpers: platform
# backtick_javascript: true

module Etc
  Group = ::Struct.new(:name, :passwd, :gid, :mem)
  Group.include ::Enumerable

  Passwd = ::Struct.new(:name, :passwd, :uid, :gid, :gecos, :dir, :shell)
  Passwd.include ::Enumerable

  class << self
    alias confstr __not_implemented__

    def endgrent
      # Ends the process of scanning through the /etc/group file begun by ::getgrent, and closes the file.
      return nil if `$platform.windows`
      if @group_file
        @group_file.close
        @group_file = nil
      end
    end

    def endpwent
      # Ends the process of scanning through the /etc/passwd file begun with ::getpwent, and closes the file.
      return nil if `$platform.windows`
      if @passwd_file
        @passwd_file.close
        @passwd_file = nil
      end
    end

    def getgrent
      # Returns an entry from the /etc/group file.
      # The first time it is called it opens the file and returns the first entry;
      # each successive call returns the next entry, or nil if the end of the file has been reached.
      return nil if `$platform.windows` || !::File.exist?('/etc/group')
      @group_file ||= ::File.new('/etc/group', 'r')
      entry = @group_file.readline
      entry = @group_file.readline while entry.start_with?('#')
      if entry
        name, passwd, gid_s, users = entry.split(':')
        Group.new(name, passwd, gid_s.to_i, users.chomp.split(','))
      end
    rescue
      nil
    end

    def getgrgid(gid = ::Process.gid)
      # Returns information about the group with specified integer group_id, as found in /etc/group.
      return nil if `$platform.windows` || !::File.exist?('/etc/group')
      gid = ::Opal.coerce_to!(gid, ::Integer, :to_int)
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name, passwd, gid_s, users = entry.split(':')
          gid_i = gid_s.to_i
          return Group.new(name, passwd, gid_i, users.chomp.split(',')) if gid == gid_i
        end
      end
      raise(::ArgumentError, "can't find group for #{gid}")
    end

    def getgrnam(name)
      # Returns information about the group with specified name, as found in /etc/group.
      return nil if `$platform.windows` || !::File.exist?('/etc/group')
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, gid_s, users = entry.split(':')
          return Group.new(name_s, passwd, gid_s.to_i, users.chomp.split(',')) if name == name_s
        end
      end
      raise(::ArgumentError, "can't find group for #{name}")
    end

    def getlogin
      # Returns the short user name of the currently logged in user.
      # Unfortunately, it is often rather easy to fool ::getlogin.
      if `$platform.windows`
        ENV['USER']
      else
        pw = getpwuid
        pw[:name] if pw
      end
    end

    def getpwent
      # Returns an entry from the /etc/passwd file.
      # The first time it is called it opens the file and returns the first entry;
      # each successive call returns the next entry, or nil if the end of the file has been reached.
      return nil if `$platform.windows` || !::File.exist?('/etc/passwd')
      @passwd_file ||= ::File.new('/etc/passwd', 'r')
      entry = @passwd_file.readline
      entry = @passwd_file.readline while entry.start_with?('#')
      if entry
        name, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
        Passwd.new(name, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell.chomp)
      end
    rescue
      nil
    end

    def getpwnam(name)
      # Returns the /etc/passwd information for the user with specified login name.
      return nil if `$platform.windows`
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      # On macOS we need to check /etc/passwd, which contains some system internal users but not regular users
      # and the directory service, which contains regular users but not all system internal users.
      # We need to check /etc/passwd first, because otherwise there may be an error.
      if `!$platform.windows` && ::File.exist?('/etc/passwd')
        ::File.open('/etc/passwd', 'r') do |passwd_file|
          passwd_file.each_line do |entry|
            next if entry.start_with?('#')
            name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
            return Passwd.new(name_s, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell.chomp) if name == name_s
          end
        end
      end
      if `$platform.macos`
        passwd_file = ::Kernel.send('`', "dscl . list /Users uid")
        passwd_file.each_line do |entry|
          name_s = `entry.replace(/\s+\w+\s*$/, '')`
          if name == name_s
            uid_i = `entry.replace(/^\w*\s+/, '')`.to_i
            passwd = ::Kernel.send('`', "dscl . read /Users/#{name_s} Password 2>&1").sub(/^\w+:\s+/, '').chomp
            gid_s  = ::Kernel.send('`', "dscl . read /Users/#{name_s} PrimaryGroupID 2>&1").sub(/^\w+:\s+/, '').chomp
            gecos  = ::Kernel.send('`', "dscl . read /Users/#{name_s} RealName 2>&1").sub(/^\w+:\s+/, '').chomp
            # Users may have multiple home directories registered in the directory service on macOS, take the first.
            dir_lines = ::Kernel.send('`', "dscl . read /Users/#{name_s} NFSHomeDirectory 2>&1").lines
            dir = dir_lines[0].sub(/^\w+:\s+/, '').chomp
            dir, _ = dir.split(' ') if dir_lines.size == 1
            shell  = ::Kernel.send('`', "dscl . read /Users/#{name_s} UserShell 2>&1").sub(/^\w+:\s+/, '').chomp
            return Passwd.new(name_s, passwd, uid_i, gid_s.to_i, gecos, dir, shell)
          end
        end
      end

      raise(::ArgumentError, "can't find user for #{name}")
    end

    def getpwuid(uid = nil)
      # Returns the /etc/passwd information for the user with the given integer uid.
      return nil if `$platform.windows`
      uid = ::Opal.coerce_to!(uid, ::Integer, :to_int) if uid
      uid ||= ::Process.uid
      # On macOS we need to check /etc/passwd, which contains some system internal users but not regular users
      # and the directory service, which contains regular users but not all system internal users.
      # We need to check /etc/passwd first, because otherwise there may be an error.
      if `!$platform.windows` && ::File.exist?('/etc/passwd')
        ::File.open('/etc/passwd', 'r') do |passwd_file|
          passwd_file.each_line do |entry|
            next if entry.start_with?('#')
            name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
            uid_i = uid_s.to_i
            return Passwd.new(name_s, passwd, uid_i, gid_s.to_i, gecos, dir, shell.chomp) if uid == uid_i
          end
        end
      end
      if `$platform.macos`
        passwd_file = ::Kernel.send('`', "dscl . list /Users uid")
        passwd_file.each_line do |entry|
          uid_i = `entry.replace(/^\w*\s+/, '')`.to_i
          if uid == uid_i
            name_s = `entry.replace(/\s+\w+\s*$/, '')`
            passwd = ::Kernel.send('`', "dscl . read /Users/#{name_s} Password 2>&1").sub(/^\w+:\s+/, '').chomp
            gid_s  = ::Kernel.send('`', "dscl . read /Users/#{name_s} PrimaryGroupID 2>&1").sub(/^\w+:\s+/, '').chomp
            gecos  = ::Kernel.send('`', "dscl . read /Users/#{name_s} RealName 2>&1").sub(/^\w+:\s+/, '').chomp
            # Users may have multiple home directories registered in the directory service on macOS, take the first.
            dir_lines = ::Kernel.send('`', "dscl . read /Users/#{name_s} NFSHomeDirectory 2>&1").lines
            dir = dir_lines[0].sub(/^\w+:\s+/, '').chomp
            dir, _ = dir.split(' ') if dir_lines.size == 1
            shell  = ::Kernel.send('`', "dscl . read /Users/#{name_s} UserShell 2>&1").sub(/^\w+:\s+/, '').chomp
            return Passwd.new(name_s, passwd, uid_i, gid_s.to_i, gecos, dir, shell)
          end
        end
      end

      raise(::ArgumentError, "can't find user for #{uid}")
    end

    def group(&block)
      # Provides a convenient Ruby iterator which executes a block for each entry in the /etc/group file.
      return nil if `$platform.windows`
      return getgrgid unless block_given?
      raise ::RuntimeError, '#passwd already active' if @group_active
      @group_active = true
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, gid_s, users = entry.split(':')
          yield Group.new(name_s, passwd, gid_s.to_i, users.chomp.split(','))
        end
      end
      nil
    ensure
      @group_active = false
    end

    def nprocessors
      # Returns the number of online processors.
      `$platform.available_parallelism()`
    end

    def passwd(&block)
      # Provides a convenient Ruby iterator which executes a block for each entry in the /etc/passwd file.
      return nil if `$platform.windows`
      return getpwuid unless block_given?
      raise ::RuntimeError, '#passwd already active' if @passwd_active
      @passwd_active = true
      ::File.open('/etc/passwd', 'r') do |passwd_file|
        passwd_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
          yield Passwd.new(name_s, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell.chomp)
        end
      end
      nil
    ensure
      @passwd_active = false
    end

    def setgrent
      # Resets the process of reading the /etc/group file,
      # so that the next call to ::getgrent will return the first entry again.
      return nil if `$platform.windows`
      @group_file.rewind if @group_file
    end

    def setpwent
      # Resets the process of reading the /etc/passwd file,
      # so that the next call to ::getpwent will return the first entry again.
      return nil if `$platform.windows`
      @passwd_file.rewind if @passwd_file
    end

    def sysconf(name)
      # Returns system configuration variable using sysconf().
      nil
    end

    def sysconfdir
      # Returns system configuration directory.
      '$platform.sysconfdir'
    end

    def systmpdir
      # Returns system temporary directory; typically “/tmp”.
      `$platform.tmpdir()`
    end

    def uname
      { sysname: `$platform.sysname()`, nodename: `$platform.nodename()`, release: `$platform.release()`,
        version: `$platform.version()`, machine: `$platform.machine()` }
    end
  end
end
