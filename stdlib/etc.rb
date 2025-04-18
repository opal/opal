# helpers: platform

module Etc
  Group = ::Struct.new(:name, :passwd, :gid, :mem)
  Group.include ::Enumerable

  Passwd = ::Struct.new(:name, :passwd, :uid, :gid, :gecos, :dir, :shell)
  Passwd.include ::Enumerable

  class << self
    def confstr(name)
      # Returns system configuration variable using confstr().
      nil
    end

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
        @passwd_file.nil
      end
    end

    def getgrent
      # Returns an entry from the /etc/group file.
      # The first time it is called it opens the file and returns the first entry;
      # each successive call returns the next entry, or nil if the end of the file has been reached.
      return nil if `$platform.windows`
      @group_file ||= ::File.new('/etc/group', 'r')
      entry = @group_file.readline
      entry = @group_file.readline while entry.start_with?('#')
      if entry
        name, passwd, gid_s, users = entry.split(':')
        Group.new(name, passwd, gid_s.to_i, users.split(','))
      end
    rescue
      nil
    end

    def getgrgid(gid = nil)
      # Returns information about the group with specified integer group_id, as found in /etc/group.
      return nil if `$platform.windows`
      gid ||= ::Process.gid
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name, passwd, gid_s, users = entry.split(':')
          gid_i = gid_s.to_i
          return Group.new(name, passwd, gid_i, users.split(',')) if gid == gid_i
        end
      end
      nil
    end

    def getgrnam(name)
      # Returns information about the group with specified name, as found in /etc/group.
      return nil if `$platform.windows`
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, gid_s, users = entry.split(':')
          return Group.new(name_s, passwd, gid_s.to_i, users.split(',')) if name == name_s
        end
      end
      nil
    end

    def getlogin
      # Returns the short user name of the currently logged in user.
      # Unfortunately, it is often rather easy to fool ::getlogin.
      return nil if `$platform.windows`
      pw = getpwuid
      return nil unless pw
      pw[:name]
    end

    def getpwent
      # Returns an entry from the /etc/passwd file.
      # The first time it is called it opens the file and returns the first entry;
      # each successive call returns the next entry, or nil if the end of the file has been reached.
      return nil if `$platform.windows`
      @passwd_file ||= ::File.new('/etc/passwd', 'r')
      entry = @passwd_file.readline
      entry = @passwd_file.readline while entry.start_with?('#')
      if entry
        name, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
        Passwd.new(name, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell)
      end
    end

    def getpwnam(name)
      # Returns the /etc/passwd information for the user with specified login name.
      return nil if `$platform.windows`
      name = ::Opal.coerce_to!(name, ::String, :to_str)
      ::File.open('/etc/passwd', 'r') do |passwd_file|
        passwd_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
          return Passwd.new(name_s, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell) if name == name_s
        end
      end
      nil
    end

    def getpwuid(uid = nil)
      # Returns the /etc/passwd information for the user with the given integer uid.
      return nil if `$platform.windows`
      uid ||= ::Process.uid
      ::File.open('/etc/passwd', 'r') do |passwd_file|
        passwd_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
          uid_i = uid_s.to_i
          return Passwd.new(name_s, passwd, uid_i, gid_s.to_i, gecos, dir, shell) if uid == uid_i
        end
      end
      nil
    end

    def group(&block)
      # Provides a convenient Ruby iterator which executes a block for each entry in the /etc/group file.
      return nil if `$platform.windows`
      return getgrgid unless block_given?
      ::File.open('/etc/group', 'r') do |group_file|
        group_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, gid_s, users = entry.split(':')
          yield Group.new(name_s, passwd, gid_s.to_i, users.split(','))
        end
      end
      nil
    end

    def nprocessors
      # Returns the number of online processors.
      `$platform.available_parallelism()`
    end

    def passwd(&block)
      # Provides a convenient Ruby iterator which executes a block for each entry in the /etc/passwd file.
      return nil if `$platform.windows`
      return getpwuid unless block_given?
      ::File.open('/etc/passwd', 'r') do |passwd_file|
        passwd_file.each_line do |entry|
          next if entry.start_with?('#')
          name_s, passwd, uid_s, gid_s, gecos, dir, shell = entry.split(':')
          yield Passwd.new(name_s, passwd, uid_s.to_i, gid_s.to_i, gecos, dir, shell)
        end
      end
      nil
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
