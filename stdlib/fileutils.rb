# inspired by ruby/lib/fileutils.rb
# adapted to Opal

module FileUtils
  # The version number.
  VERSION = "1.7.3"

  # helpers
  # These are attached to a module so the method namespace of ::FileUtils is clean, cause it needs to.
  module Helpers_
    def fu_copy_metadata(path, target)
      st = ::File.lstat(path)
      if !st.symlink?
        File.utime st.atime, st.mtime, target
      end
      mode = st.mode
      begin
        if st.symlink?
          begin
            ::File.lchown st.uid, st.gid, target
          rescue NotImplementedError
          end
        else
          ::File.chown st.uid, st.gid, target
        end
      rescue Errno::EPERM, Errno::EACCES
        # clear setuid/setgid
        mode &= 01777
      end
      if st.symlink?
        begin
          ::File.lchmod mode, target
        rescue NotImplementedError, Errno::EOPNOTSUPP
        end
      else
        ::File.chmod mode, target
      end
    end
    module_function :fu_copy_metadata

    def fu_descendant_directory(descendant, ascendant)
      if File::FNM_SYSCASE.nonzero?
        File.expand_path(File.dirname(descendant)).casecmp(File.expand_path(ascendant)) == 0
      else
        File.expand_path(File.dirname(descendant)) == File.expand_path(ascendant)
      end
    end
    module_function :fu_descendant_directory

    def fu_each_src_dest0(src, dest, target_directory = true, &block)
      if tmp = Array.try_convert(src)
        tmp.each do |s|
          s = File.path(s)
          block.call s, (target_directory ? ::File.join(dest, File.basename(s)) : dest)
        end
      else
        src = File.path(src)
        if target_directory and ::File.directory?(dest)
          block.call src, ::File.join(dest, File.basename(src))
        else
          block.call src, File.path(dest)
        end
      end
    end
    module_function :fu_each_src_dest0

    def fu_each_src_dest(src, dest, &block)
      fu_each_src_dest0(src, dest) do |s, d|
        raise ArgumentError, "same file: #{s} and #{d}" if ::File.identical?(s, d)
        block.call s, d
      end
    end
    module_function :fu_each_src_dest

    def fu_get_gid(group)
      return nil unless group
      case group
      when Integer
        group
      when /\A\d+\z/
        group.to_i
      else
        require 'etc'
        Etc.getgrnam(group) ? Etc.getgrnam(group).gid : nil
      end
    end
    module_function :fu_get_gid

    def fu_get_uid(user)
      return nil unless user
      case user
      when Integer
        user
      when /\A\d+\z/
        user.to_i
      else
        require 'etc'
        Etc.getpwnam(user) ? Etc.getpwnam(user).uid : nil
      end
    end
    module_function :fu_get_uid

    def fu_have_symlink
      ::File.symlink nil, nil
    rescue ::TypeError
      return true
    rescue
      return false
    end
    module_function :fu_have_symlink

    def fu_mode(mode, path)
      apply_mask = ->(mode, user_mask, op, mode_mask) do
        case op
        when '='
          (mode & ~user_mask) | (user_mask & mode_mask)
        when '+'
          mode | (user_mask & mode_mask)
        when '-'
          mode & ~(user_mask & mode_mask)
        end
      end

      get_user_mask = ->(target) do
        target.each_char.inject(0) do |mask, chr|
          case chr
          when "u"
            mask | 04700
          when "g"
            mask | 02070
          when "o"
            mask | 01007
          when "a"
            mask | 07777
          else
            raise ArgumentError, "invalid 'who' symbol in file mode: #{chr}"
          end
        end
      end

      symbolic_modes_to_i = ->(mode_sym, path) do
        path = ::File.stat(path) unless File::Stat === path
        mode = path.mode
        mode_sym.split(/,/).inject(mode & 07777) do |current_mode, clause|
          target, *actions = clause.split(/([=+-])/)
          raise ArgumentError, "invalid file mode: #{mode_sym}" if actions.empty?
          target = 'a' if target.empty?
          user_mask = get_user_mask.call(target)
          actions.each_slice(2) do |op, perm|
            need_apply = op == '='
            mode_mask = (perm || '').each_char.inject(0) do |mask, chr|
              case chr
              when "r"
                mask | 0444
              when "w"
                mask | 0222
              when "x"
                mask | 0111
              when "X"
                if path.directory?
                  mask | 0111
                else
                  mask
                end
              when "s"
                mask | 06000
              when "t"
                mask | 01000
              when "u", "g", "o"
                if mask.nonzero?
                  current_mode = apply_mask.call(current_mode, user_mask, op, mask)
                end
                need_apply = false
                copy_mask = get_user_mask.call(chr)
                (current_mode & copy_mask) / (copy_mask & 0111) * (user_mask & 0111)
              else
                raise ArgumentError, "invalid 'perm' symbol in file mode: #{chr}"
              end
            end

            if mode_mask.nonzero? || need_apply
              current_mode = apply_mask.call(current_mode, user_mask, op, mode_mask)
            end
          end
          current_mode
        end
      end

      mode.is_a?(String) ? symbolic_modes_to_i.call(mode, path) : mode
    end
    module_function :fu_mode

    def fu_output_message(msg)
      output = @fileutils_output if defined?(@fileutils_output)
      output ||= $stdout
      if defined?(@fileutils_label)
        msg = @fileutils_label + msg
      end
      output.puts msg
    end
    module_function :fu_output_message

    def fu_postorder_traverse(root, &block)
      if ::File.lstat(root).directory?
        begin
          children = ::Dir.children(root)
        rescue Errno::EACCES
          # Failed to get the list of children.
          # Assuming there are no children, try to process the parent directory.
          return block.call root
        end

        children.each do |ent|
          fu_postorder_traverse(::File.join(root, ent), &block)
        end
      end
      block.call root
    end
    module_function :fu_postorder_traverse

    def fu_preorder_traverse(root, deref = false, &block)
      stack = []
      entry = root
      st = deref ? ::File.stat(root) : ::File.lstat(root)
      while entry
        block.call entry, st
        if st.directory?
          entries = ::Dir.children(entry).reverse.map do |e|
            path = ::File.join(entry, e)
            [path, ::File.lstat(path)]
          end
          stack.concat(entries)
        end
        entry, st = stack.pop
      end
    end
    module_function :fu_preorder_traverse

    def fu_wrap_traverse(root, pre, post)
      pre.call root
      if ::File.lstat(root).directory?
        ::Dir.children(root).each do |ent|
          fu_wrap_traverse(::File.join(root, ent), pre, post)
        end
      end
      post.call root
    end
    module_function :fu_wrap_traverse
  end

  # actual module methods

  def chdir(dir, verbose: nil, &block)
    # Changes the working directory to the given dir, which
    # should be interpretable as a path
    Helpers_.fu_output_message "cd #{dir}" if verbose
    result = ::Dir.chdir(dir, &block)
    Helpers_.fu_output_message 'cd -' if verbose and block
    result
  end
  module_function :chdir

  alias cd chdir
  module_function :cd

  def chmod(mode, list, noop: nil, verbose: nil)
    # Changes permissions on the entries at the paths given in list (a single path or an array of paths)
    # to the permissions given by mode; returns list if it is an array, [list] otherwise
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message sprintf('chmod %s %s',
                                      mode.is_a?(::String) ? mode : "%o" % mode, list.join(' ')) if verbose
    return if noop
    list.each do |path|
      chmode = Helpers_.fu_mode(mode, path)
      ::File.symlink?(path) ? ::File.lchmod(chmode, path) : ::File.chmod(chmode, path)
    end
  end
  module_function :chmod

  def chmod_R(mode, list, noop: nil, verbose: nil, force: nil)
    # Like FileUtils.chmod, but changes permissions recursively.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message sprintf('chmod -R%s %s %s', (force ? 'f' : ''),
                              mode.is_a?(String) ? mode : "%o" % mode, list.join(' ')) if verbose
    return if noop
    list.each do |root|
      Helpers_.fu_preorder_traverse(root) do |path|
        chmode = Helpers_.fu_mode(mode, path)
        begin
          ::File.symlink?(path) ? ::File.lchmod(chmode, path) : ::File.chmod(chmode, path)
        rescue
          raise unless force
        end
      end
    end
  end
  module_function :chmod_R

  def chown(user, group, list, noop: nil, verbose: nil)
    # Changes the owner and group on the entries at the paths given in list (a single path or an array of paths)
    # to the given user and group; returns list if it is an array, [list] otherwise
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message sprintf('chown %s %s',
                              (group ? "#{user}:#{group}" : user || ':'),
                              list.join(' ')) if verbose
    return if noop
    uid = Helpers_.fu_get_uid(user)
    gid = Helpers_.fu_get_gid(group)
    list.each do |path|
      ::File.symlink?(path) ? ::File.lchown(uid, gid, path) : ::File.chown(uid, gid, path)
    end
  end
  module_function :chown

  def chown_R(user, group, list, noop: nil, verbose: nil, force: nil)
    # Like FileUtils.chown, but changes owner and group recursively.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message sprintf('chown -R%s %s %s',
                              (force ? 'f' : ''),
                              (group ? "#{user}:#{group}" : user || ':'),
                              list.join(' ')) if verbose
    return if noop
    uid = Helpers_.fu_get_uid(user)
    gid = Helpers_.fu_get_gid(group)
    list.each do |root|
      Helpers_.fu_preorder_traverse(root) do |path, st|
        begin
          st.symlink? ? ::File.lchown(uid, gid, path) : ::File.chown(uid, gid, path)
        rescue
          raise unless force
        end
      end
    end
  end
  module_function :chown_R

  def cmp(a, b)
    # Returns true if the contents of files a and b are identical, false otherwise.
    return false unless File.size(a) == File.size(b)
    ::File.open(a, 'rb') {|fa|
      ::File.open(b, 'rb') {|fb|
        return compare_stream(fa, fb)
      }
    }
  end
  module_function :cmp

  alias compare_file cmp
  module_function :compare_file

  def compare_stream(a, b)
    # Returns true if the contents of streams a and b are identical, false otherwise.
    bsizes = [a, b].map do |s|
                         next unless s.respond_to?(:stat)
                         size = s.stat.blksize
                         size if size and size > 0
                       end
    bsize = bsizes.min || 1024

    begin
      sa = a.read(bsize)
      sb = b.read(bsize)
      return true if sa.nil? && sb.nil?
    end while sa == sb
    false
  end
  module_function :compare_stream

  def copy(src, dest, preserve: nil, noop: nil, verbose: nil)
    # Copies files.
    Helpers_.fu_output_message "cp#{preserve ? ' -p' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest(src, dest) do |s, d|
      copy_file s, d, preserve
    end
  end
  module_function :copy

  def copy_entry(src, dest, preserve = false, dereference_root = false, remove_destination = false)
    # Recursively copies files from src to dest.
    if dereference_root
      src = File.realpath(src)
    end

    Helpers_.fu_wrap_traverse(src, proc do |ent|
      rel = `ent.slice(src.length + 1)`
      destent = rel.nil? || rel.empty? ? dest : ::File.join(dest, rel)
      ::File.unlink destent if remove_destination && (::File.file?(destent) || ::File.symlink?(destent))
      st = ::File.lstat(ent)
      case
      when st.file?
        ::File.open(ent) do |s|
          ::File.open(destent, 'wb', st.mode) do |f|
            ::IO.copy_stream(s, f)
          end
        end
      when st.directory?
        if !::File.exist?(destent) and Helpers_.fu_descendant_directory(destent, ent)
          raise ArgumentError, "cannot copy directory %s to itself %s" % [ent, destent]
        end
        begin
          ::Dir.mkdir destent
        rescue
          raise unless ::File.directory?(destent)
        end
      when st.symlink?
        ::File.symlink ::File.readlink(ent), destent
      when st.chardev?, st.blockdev?
        raise "cannot handle device file"
      when st.socket?
        begin
          require 'socket'
        rescue LoadError
          raise "cannot handle socket"
        else
          raise "cannot handle socket" unless defined?(UNIXServer)
        end
        UNIXServer.new(destent).close
        ::File.chmod st.mode, destent
      when st.pipe?
        raise "cannot handle FIFO" unless ::File.respond_to?(:mkfifo)
        ::File.mkfifo destent, st.mode
      when st.mode & 0xF000 == 0xD000 # S_IF_DOOR = 0xD000
        raise "cannot handle door: #{ent}"
      else
        raise "unknown file type: #{ent}"
      end
    end, proc do |ent|
      rel = `ent.slice(src.length + 1)`
      destent = rel.nil? || rel.empty? ? dest : ::File.join(dest, rel)
      Helpers_.fu_copy_metadata(ent, destent) if preserve
    end)
  end
  module_function :copy_entry

  def copy_file(src, dest, preserve = false, dereference = true)
    # Copies file from src to dest, which should not be directories.
    ::File.open(src) do |s|
      ::File.open(dest, 'wb', s.stat.mode) do |f|
        ::IO.copy_stream(s, f)
      end
    end
    Helpers_.fu_copy_metadata(src, dest) if preserve
  end
  module_function :copy_file

  def copy_stream(src, dest)
    # Copies IO stream src to IO stream dest via IO.copy_stream.
    ::IO.copy_stream(src, dest)
  end
  module_function :copy_stream

  alias cp copy
  module_function :cp

  def cp_lr(src, dest, noop: nil, verbose: nil, dereference_root: true, remove_destination: false)
    # Create hard links instead of copying files
    Helpers_.fu_output_message "cp -lr#{remove_destination ? ' --remove-destination' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest(src, dest) do |s, d|
      link_entry s, d, dereference_root, remove_destination
    end
  end
  module_function :cp_lr

  def cp_r(src, dest, preserve: nil, noop: nil, verbose: nil, dereference_root: true, remove_destination: nil)
    # Recursively copies files.
    Helpers_.fu_output_message "cp -r#{preserve ? 'p' : ''}#{remove_destination ? ' --remove-destination' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest(src, dest) do |s, d|
      copy_entry s, d, preserve, dereference_root, remove_destination
    end
  end
  module_function :cp_r

  def getwd
    # Returns a string containing the path to the current directory
    ::Dir.pwd
  end
  module_function :getwd

  alias identical? cmp
  module_function :identical?

  def install(src, dest, mode: nil, owner: nil, group: nil, preserve: nil, noop: nil, verbose: nil)
    # Copies a file entry. See install(1).
    if verbose
      msg = +"install -c"
      msg << ' -p' if preserve
      msg << ' -m ' << (mode.is_a?(String) ? mode : "%o" % mode) if mode
      msg << " -o #{owner}" if owner
      msg << " -g #{group}" if group
      msg << ' ' << [src,dest].flatten.join(' ')
      Helpers_.fu_output_message msg
    end
    return if noop
    uid = Helpers_.fu_get_uid(owner)
    gid = Helpers_.fu_get_gid(group)
    Helpers_.fu_each_src_dest(src, dest) do |s, d|
      st = ::File.stat(s)
      unless ::File.exist?(d) and compare_file(s, d)
        remove_file d, true
        if d.end_with?('/')
          mkdir_p d
          copy_file s, d + ::File.basename(s)
        else
          mkdir_p ::File.expand_path('..', d)
          copy_file s, d
        end
        ::File.utime st.atime, st.mtime, d if preserve
        ::File.chmod Helpers_.fu_mode(mode, st), d if mode
        ::File.chown uid, gid, d if uid or gid
      end
    end
  end
  module_function :install

  def link(src, dest, force: nil, noop: nil, verbose: nil)
    # Creates hard links
    Helpers_.fu_output_message "ln#{force ? ' -f' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest0(src, dest) do |s,d|
      remove_file d, true if force
      ::File.link s, d
    end
  end
  module_function :link

  def link_entry(src, dest, dereference_root = false, remove_destination = false)
    # Creates hard links; returns nil.
    Helpers_.fu_preorder_traverse(src, dereference_root) do |ent, st|
      rel = `ent.slice(src.length + 1)`
      destent = rel.nil? || rel.empty? ? dest : ::File.join(dest, rel)
      ::File.unlink(destent) if remove_destination && ::File.file?(destent)
      if st.directory?
        if !::File.exist?(destent) and Helpers_.fu_descendant_directory(destent, ent)
          raise ArgumentError, "cannot link directory %s to itself %s" % [ent, destent]
        end
        begin
          ::Dir.mkdir destent
        rescue
          raise unless ::File.directory?(destent)
        end
      else
        ::File.link ent, destent
      end
    end
  end
  module_function :link_entry

  alias ln link
  module_function :ln

  def ln_s(src, dest, force: nil, relative: false, target_directory: true, noop: nil, verbose: nil)
    # Creates symbolic links
    if relative
      return ln_sr(src, dest, force: force, noop: noop, verbose: verbose)
    end
    Helpers_.fu_output_message "ln -s#{force ? 'f' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest0(src, dest) do |s,d|
      remove_file d, true if force
      File.symlink s, d
    end
  end
  module_function :ln_s

  def ln_sf(src, dest, noop: nil, verbose: nil)
    # Like FileUtils.ln_s, but always with keyword argument force: true given.
    ln_s src, dest, force: true, noop: noop, verbose: verbose
  end
  module_function :ln_sf

  def ln_sr(src, dest, target_directory: true, force: nil, noop: nil, verbose: nil)
    # Like FileUtils.ln_s, but create links relative to dest.
    options = "#{force ? 'f' : ''}#{target_directory ? '' : 'T'}"
    dest = File.path(dest)
    srcs = Array(src)

    fu_clean_components = ->(*comp) do
      comp.shift while comp.first == "."
      return comp if comp.empty?
      clean = [comp.shift]
      path = ::File.join(*clean, "") # ending with File::SEPARATOR
      while c = comp.shift
        if c == ".." and clean.last != ".." and !(fu_have_symlink && ::File.symlink?(path))
          clean.pop
          path.chomp!(%r((?<=\A|/)[^/]+/\z), "")
        else
          clean << c
          path += c + "/"
        end
      end
      clean
    end

    fu_relative_components_from = ->(target, base) do
      i = 0
      while target[i]&.== base[i]
        i += 1
      end
      Array.new(base.size-i, '..').concat(target[i..-1])
    end

    fu_split_path = ->(path) do
      path = File.path(path)
      list = []
      until (parent, base = File.split(path); parent == path or parent == ".")
        list << base
        path = parent
      end
      list << path
      list.reverse!
    end

    fu_starting_path = ->(path) do
      if `Opal.platform.windows`
        path&.start_with?(%r(\w:|/))
      else
        path&.start_with?("/")
      end
    end

    link = proc do |s, target_dir_p = true|
      s = File.path(s)
      if target_dir_p
        d = ::File.join(destdirs = dest, File.basename(s))
      else
        destdirs = File.dirname(d = dest)
      end
      destdirs = fu_split_path.call(File.realpath(destdirs))
      if fu_starting_path.call(s)
        srcdirs = fu_split_path.call((File.realdirpath(s) rescue File.expand_path(s)))
        base = fu_relative_components_from.call(srcdirs, destdirs)
        s = ::File.join(*base)
      else
        srcdirs = fu_clean_components.call(*fu_split_path.call(s))
        base = fu_relative_components_from.call(fu_split_path.call(Dir.pwd), destdirs)
        while srcdirs.first&. == ".." and base.last&.!=("..") and !fu_starting_path.call(base.last)
          srcdirs.shift
          base.pop
        end
        s = ::File.join(*base, *srcdirs)
      end
      Helpers_.fu_output_message "ln -s#{options} #{s} #{d}" if verbose
      next if noop
      remove_file d, true if force
      File.symlink s, d
    end
    case srcs.size
    when 0
    when 1
      link[srcs[0], target_directory && ::File.directory?(dest)]
    else
      srcs.each(&link)
    end
  end
  module_function :ln_sr

  def makedirs(list, mode: nil, noop: nil, verbose: nil)
    # Creates directories at the paths in the given list (a single path or an array of paths),
    # also creating ancestor directories as needed; returns list if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message "mkdir -p #{mode ? ('-m %03o ' % mode) : ''}#{list.join ' '}" if verbose
    return *list if noop

    list.each do |item|
      path = item == '/' ? item : item.chomp(?/)

      stack = []
      until ::File.directory?(path) || File.dirname(path) == path
        stack.push path
        path = File.dirname(path)
      end
      stack.reverse_each do |dir|
        begin
          dir = dir == '/' ? dir : dir.chomp(?/)
          if mode
            Dir.mkdir dir, mode
            ::File.chmod mode, dir
          else
            Dir.mkdir dir
          end
        rescue SystemCallError
          raise unless ::File.directory?(dir)
        end
      end
    end

    return *list
  end
  module_function :makedirs

  def mkdir(list, mode: nil, noop: nil, verbose: nil)
    # Creates directories at the paths in the given list (a single path or an array of paths);
    # returns list if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message "mkdir #{mode ? ('-m %03o ' % mode) : ''}#{list.join ' '}" if verbose
    return if noop

    list.each do |dir|
      dir = dir == '/' ? dir : dir.chomp(?/)
      if mode
        Dir.mkdir dir, mode
        ::File.chmod mode, dir
      else
        Dir.mkdir dir
      end
    end
  end
  module_function :mkdir

  alias mkdir_p makedirs
  module_function :mkdir_p

  alias mkpath makedirs
  module_function :mkpath


  def move(src, dest, force: nil, noop: nil, verbose: nil, secure: nil)
    # Moves entries.
    Helpers_.fu_output_message "mv#{force ? ' -f' : ''} #{[src,dest].flatten.join ' '}" if verbose
    return if noop
    Helpers_.fu_each_src_dest(src, dest) do |s, destent|
      begin
        if ::File.exist?(destent)
          if ::File.directory?(destent)
            raise Errno::EEXIST, destent
          end
        end
        begin
          File.rename s, destent
        rescue Errno::EXDEV,
               Errno::EPERM # move from unencrypted to encrypted dir (ext4)
          copy_entry s, destent, true
          if secure
            remove_entry_secure s, force
          else
            remove_entry s, force
          end
        end
      rescue SystemCallError
        raise unless force
      end
    end
  end
  module_function :move

  alias mv move
  module_function :mv

  alias pwd getwd
  module_function :pwd

  def remove(list, force: nil, noop: nil, verbose: nil)
    # Removes entries at the paths in the given list (a single path or an array of paths)
    # returns list, if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message "rm#{force ? ' -f' : ''} #{list.join ' '}" if verbose
    return if noop

    list.each do |path|
      remove_file path, force
    end
  end
  module_function :remove

  def remove_dir(path, force = false)
    # Recursively removes the directory entry given by +path+,
    # which should be the entry for a regular file, a symbolic link,
    # or a directory.
    remove_entry path, force   # FIXME?? check if it is a directory
  end
  module_function :remove_dir

  def remove_entry(path, force = false)
    # Removes the entry given by path, which should be the entry for a regular file, a symbolic link, or a directory.
    Helpers_.fu_postorder_traverse(path) do |ent|
      begin
        if ::File.lstat(ent).directory?
          begin
            ent = ent.to_s unless ent.is_a?(::String)
            ent = ent.chomp(?/)
            ::Dir.rmdir ent
          rescue
            if `Opal.platform.windows`
              begin
                ::File.chmod(0700, ent)
                ::Dir.rmdir(ent)
              rescue
                raise
              end
            else
              raise
            end
          end
        else
          remove_file ent
        end
      rescue
        raise unless force
      end
    end
  rescue
    raise unless force
  end
  module_function :remove_entry

  def remove_entry_secure(path, force = false)
    # Securely removes the entry given by path, which should be the entry for a regular file, a symbolic link,
    # or a directory.
    unless Helpers_.fu_have_symlink
      remove_entry path, force
      return
    end
    fullpath = ::File.expand_path(path)
    st = ::File.lstat(fullpath)
    unless st.directory?
      ::File.unlink fullpath
      return
    end
    # is a directory.
    parent_st = ::File.stat(::File.dirname(fullpath))
    unless parent_st.world_writable?
      remove_entry path, force
      return
    end
    unless parent_st.sticky?
      raise ArgumentError, "parent directory is world writable, FileUtils#remove_entry_secure does not work; abort: #{path.inspect} (parent directory mode #{'%o' % parent_st.mode})"
    end

    # freeze tree root
    euid = Process.euid
    dot_file = fullpath + "/."
    begin
      ::File.open(dot_file) do |f|
        fst = f.stat
        unless st.dev == fst.dev and st.ino == fst.ino
          # symlink (TOC-to-TOU attack?)
          ::File.unlink fullpath
          return
        end
        f.chown euid, -1
        f.chmod 0700
      end
    rescue Errno::EISDIR # JRuby in non-native mode can't open files as dirs
      ::File.lstat(dot_file).tap do |fstat|
        unless st.dev == fstat.dev and st.ino == fstat.ino
          # symlink (TOC-to-TOU attack?)
          ::File.unlink fullpath
          return
        end
        ::File.chown euid, -1, dot_file
        ::File.chmod 0700, dot_file
      end
    end

    fst = ::File.lstat(fullpath)
    unless st.dev == fst.dev and st.ino == fst.ino
      # TOC-to-TOU attack?
      ::File.unlink fullpath
      return
    end

    # ---- tree root is frozen ----
    Helpers_.fu_preorder_traverse(path) do |entry, st|
      if st.directory?
        ::File.chown(euid, -1, entry)
        ::File.chmod(0700, entry)
      end
    end
    remove_entry(path, force)
  rescue => e
    raise e unless force
  end
  module_function :remove_entry_secure

  def remove_file(path, force = false)
    # Removes the file entry given by path, which should be the entry for a regular file or a symbolic link.
    ::File.unlink(path)
  rescue
    if `Opal.platform.windows`
      begin
        ::File.chmod(0700, path)
        ::File.unlink(path)
      rescue
        raise unless force
      end
    else
      raise unless force
    end
  end
  module_function :remove_file

  alias rm remove
  module_function :rm

  def rm_f(list, noop: nil, verbose: nil)
    # Equivalent to: FileUtils.rm(list, force: true, **kwargs)
    rm list, force: true, noop: noop, verbose: verbose
  end
  module_function :rm_f

  def rm_r(list, force: nil, noop: nil, verbose: nil, secure: nil)
    # Removes entries at the paths in the given list (a single path or an array of paths);
    # returns list, if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message "rm -r#{force ? 'f' : ''} #{list.join ' '}" if verbose
    return if noop
    list.each do |path|
      if secure
        remove_entry_secure path, force
      else
        remove_entry path, force
      end
    end
  end
  module_function :rm_r

  def rm_rf(list, noop: nil, verbose: nil, secure: nil)
    # Equivalent to: FileUtils.rm_r(list, force: true, **kwargs)
    rm_r list, force: true, noop: noop, verbose: verbose, secure: secure
  end
  module_function :rm_rf

  def rmdir(list, parents: nil, noop: nil, verbose: nil)
    # Removes directories at the paths in the given list (a single path or an array of paths);
    # returns list, if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    Helpers_.fu_output_message "rmdir #{parents ? '-p ' : ''}#{list.join ' '}" if verbose
    return if noop
    list.each do |dir|
      ::Dir.rmdir(dir = dir == '/' ? dir : dir.chomp(?/))
      if parents
        begin
          until (parent = File.dirname(dir)) == '.' or parent == dir
            dir = parent
            ::Dir.rmdir(dir)
          end
        rescue Errno::ENOTEMPTY, Errno::EEXIST, Errno::ENOENT
        end
      end
    end
  end
  module_function :rmdir

  alias rmtree rm_rf
  module_function :rmtree

  alias safe_unlink rm_f
  module_function :safe_unlink

  alias symlink ln_s
  module_function :symlink

  def touch(list, noop: nil, verbose: nil, mtime: nil, nocreate: nil)
    # Updates modification times (mtime) and access times (atime) of the entries given by the paths in list
    # (a single path or an array of paths); returns list if it is an array, [list] otherwise.
    list = [list].flatten.map { |path| ::File.path(path) }
    t = mtime
    if verbose
      Helpers_.fu_output_message "touch #{nocreate ? '-c ' : ''}#{t ? t.strftime('-t %Y%m%d%H%M.%S ') : ''}#{list.join ' '}"
    end
    return if noop
    list.each do |path|
      created = nocreate
      begin
        ::File.utime(t, t, path)
      rescue Errno::ENOENT
        raise if created
        ::File.open(path, 'a') do
          ;
        end
        created = true
        retry if t
      end
    end
  end
  module_function :touch

  def uptodate?(new, old_list)
    # Returns true if the file at path new is newer than all the files at paths in array old_list; false otherwise.
    return false unless ::File.exist?(new)
    new_time = File.mtime(new)
    old_list.each do |old|
      if ::File.exist?(old)
        return false unless new_time > File.mtime(old)
      end
    end
    true
  end
  module_function :uptodate?

  # This hash table holds command options.
  OPT_TABLE = {}
  (private_instance_methods & methods(false)).inject(OPT_TABLE) {|tbl, name|
    (tbl[name.to_s] = instance_method(name).parameters).map! {|t, n| n if t == :key}.compact!
    tbl
  }

  def self.commands
    # Returns an array of the string names of FileUtils methods that accept one or more keyword arguments
    OPT_TABLE.keys
  end

  def self.options
    # Returns an array of the string keyword names
    OPT_TABLE.values.flatten.uniq.map {|sym| sym.to_s }
  end

  def self.have_option?(mid, opt)
    # Returns true if method mid accepts the given option opt, false otherwise.
    li = OPT_TABLE[mid.to_s] or raise ArgumentError, "no such method: #{mid}"
    li.include?(opt)
  end

  def self.options_of(mid)
    # Returns an array of the string keyword name for method mid.
    OPT_TABLE[mid.to_s].map {|sym| sym.to_s }
  end

  def self.collect_method(opt)
    # Returns an array of the string method names of the methods that accept the given keyword option opt.
    OPT_TABLE.keys.select {|m| OPT_TABLE[m].include?(opt) }
  end

  LOW_METHODS = singleton_methods(false) - collect_method(:noop).map(&:intern)

  module LowMethods
    private
    def _do_nothing(*)end
    ::FileUtils::LOW_METHODS.map {|name| alias_method name, :_do_nothing}
  end

  METHODS = singleton_methods() - [:private_module_function, :commands, :options, :have_option?,
                                   :options_of, :collect_method]

  module DryRun
    include FileUtils
    include LowMethods
    names = ::FileUtils.collect_method(:noop)
    names.each do |name|
      module_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def #{name}(*args, **options)
          super(*args, **options, noop: true, verbose: true)
        end
      EOS
    end
    extend self
    class << self
      public(*::FileUtils::METHODS)
    end
  end

  module NoWrite
    include FileUtils
    include LowMethods
    names = ::FileUtils.collect_method(:noop)
    names.each do |name|
      module_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def #{name}(*args, **options)
          super(*args, **options, noop: true)
        end
      EOS
    end
    extend self
    class << self
      public(*::FileUtils::METHODS)
    end
  end

  module Verbose
    include FileUtils
    names = ::FileUtils.collect_method(:verbose)
    names.each do |name|
      module_eval(<<-EOS, __FILE__, __LINE__ + 1)
        def #{name}(*args, **options)
          super(*args, **options, verbose: true)
        end
      EOS
    end
    extend self
    class << self
      public(*::FileUtils::METHODS)
    end
  end
end
