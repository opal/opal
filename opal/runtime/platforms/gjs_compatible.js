//
// Gnome GJS and Cinnamon CJS
//
if ("gjs" === Opal.platform.name) {
Opal.queue(async function() {

const platform = Opal.platform;

// imports
// platform.ByteArray = imports.bytearray;
const glib = imports.gi.GLib;
const gio = imports.gi.Gio;
const system = imports.system;

// helpers
function not_available(fun) {
  platform.handle_unsupported_feature(fun + " is not available on gjs and compatible platforms");
  return Opal.nil;
}

// RUBY_PLATFORM and some OS dependent switches
// assume linux to get linux specific specs running
platform.ruby_platform = "opal linux"; // TODO detect real OS
platform.windows = false;
platform.fs_casefold = false
platform.null_device = "/dev/null";
platform.sysconfdir = "/etc"
platform.path_sep = ":";

// Some platform info
// TODO detect real info
platform.available_parallelism = glib.get_num_processors;
platform.machine = ()=>"machine";
platform.nodename = glib.get_host_name;
platform.release = ()=>"release";
platform.sysname = ()=>"type";
platform.tmpdir = glib.get_tmp_dir;
platform.version = ()=>"unknown";

// Exit
platform.exit = system.exit;

// ARGV
platform.argv = ARGV;

// ENV
platform.env_keys = ()=>glib.listenv();
platform.env_get = (key)=>glib.getenv(key.toString());
platform.env_del = (key)=>glib.unsetenv(key.toString());
platform.env_has = (key)=>typeof glib.getenv(key.toString()) === "string";
platform.env_set = (key, value)=>glib.setenv(key.toString(), value.toString(), true);

// Process
platform.process_getegid = ()=>-1;
platform.process_setegid = ()=>-1;
platform.process_geteuid = ()=>-1;
platform.process_seteuid = ()=>-1;
platform.process_getgid = ()=>-1;
platform.process_setgid = ()=>-1;
platform.process_getgroups = ()=>[];
platform.process_getuid = ()=>-1;
platform.process_setuid = ()=>-1;
platform.process_kill = ()=>not_available("Proc#kill");
platform.process_sig_list = new Map();
platform.process_pid = ()=>not_available("Proc#pid");
platform.process_ppid = ()=>not_available("Proc#ppid");
platform.process_set_title = ()=>not_available("Proc#setproctitle");
platform.process_is_primary = ()=>not_available("#fork");
platform.process_is_worker = ()=>not_available("#fork");
platform.process_fork = ()=>not_available("#fork");
platform.process_worker_pid = ()=>not_available("#fork");
platform.process_exec = ()=>not_available("#exec");
platform.process_spawn = function() {
  for(let i = 0; i < arguments.length; i++) {
    if (arguments[i] instanceof String) arguments[i] = arguments[i].toString();
  }
  let status = glib.spawn_sync(null, arguments, null, glib.SpawnFlags.DEFAULT, null);
  return status[0];
}

// IO
// In gjs IO works with Objects, so we need to emulate fd's.
let fd_objects = { __proto__: null };

function flags_to_props(obj, flags) {
  // TODO emulate ctx
  const o = Opal.File.Constants;
  try {
    if (flags === (o.APPEND | o.CREAT | o.EXCL | o.RDWR)) { obj.read = obj.append = true; return obj; }
    if (flags === (o.APPEND | o.CREAT | o.RDWR)) { obj.read = obj.append = true; return obj; }
    if (flags === (o.APPEND | o.CREAT | o.EXCL | o.WRONLY)) { obj.append = true; return obj; }
    if (flags === (o.APPEND | o.CREAT | o.WRONLY)) { obj.append = true; return obj; }
    if (flags === (o.RDWR   | o.CREAT | o.EXCL | o.TRUNC)) { obj.read = obj.write = true; return obj; }
    if (flags === (o.RDWR   | o.CREAT | o.TRUNC)) { obj.read = obj.write = true; return obj; }
    if (flags === (o.WRONLY | o.CREAT | o.EXCL | o.TRUNC)) { obj.write = true; return obj; }
    if (flags === (o.WRONLY | o.CREAT | o.TRUNC)) { obj.write = true; return obj; }
    if (flags === o.RDWR) { obj.read = obj.write = true; return obj; }
    if (flags === o.RDONLY) { obj.read = true; return obj; }
  } catch (e) {
    // TODO throw ruby exceptions
    throw(e);
  }
}

platform.io_close = function(fd) {
  if (fd < 3) return; // don't close basic io for gjs
  if (fd_objects[fd]) {
    glib.close(fd);
    delete fd_objects[fd];
  }
}
platform.io_fdatasync = function(fd) {
  if (fd < 3) return;
  let object = fd_objects[fd], channel = object?.channel;
  if (object?.write || object?.append) channel.flush;
}
platform.io_fstat = ()=>not_available("IO#fstat"); // FileIOStream.query_info -> FileInfo
platform.io_fsync = function(fd) {
  if (fd < 3) return;
  let object = fd_objects[fd], channel = object?.channel;
  if (object?.write || object?.append) channel.flush;
}
platform.io_ioctl = ()=>not_available("IO#ioctl");
platform.io_open = (fd, flags)=>{
  object = { channel: glib.IOChannel.unix_new(fd) };
  fd_objects[fd] = flags_to_props(object, flags);
  return fd < 3 ? true : false;
}
platform.io_open_path = (path_name, flags, perm)=>glib.open(path_name.toString(), flags, perm);
platform.io_read = function(fd, io_buffer, buffer_offset, pos, count) {
  let object = fd_objects[fd], channel = object?.channel, ret, data;
  if (!object?.read) Opal.Kernel.$raise(Opal.IOError, "closed read");
  if (fd > 2) channel.seek_position(pos, glib.SeekType.SET);
  // GLib IOChannel:
  // IOChannel.read crashes and is deprecated
  // IOChannel.read_chars doesn't work at all not matter what:
  //   typein:16:3 Error: Function GLib.IOChannel.read_chars() cannot be called:
  //   argument 'buf' with type array is not introspectable because it has a type
  //   not supported for (out caller-allocates)
  // IOChannel.read_line works and returns a String that may have been encoded, but we need the raw bytes here
  // IOChannel.read_unichar same problem
  // IOChannel.read_to_end works and returns a nice Array of Bytes, so lets use that.
  //   Sure, performance goes out the window, 'cause we always read to the end.
  //   We could cache, but if we would, we also would have to stat and check for changes on each read,
  //   which is also bad for performance.
  //   So for the moment simply read_to_end each time and slice the returned Array to size.
  ret, data = stream.read_to_end();
  if (count < data.length) data = data.slice(0, count);
  (new Uint8Array(io_buffer.data_view.buffer)).set(data, buffer_offset);
  return data.length;
};
platform.io_write = function(fd, io_buffer, buffer_offset, pos, count) {
  let object = fd_objects[fd], channel = object?.channel, ret, len, data;
  if (!(object?.write || object?.append)) Opal.Kernel.$raise(Opal.IOError, "closed write");
  if (object.append) channel.seek_position(0, glib.SeekType.END);
  else if (fd > 2) channel.seek_position(pos, glib.SeekType.SET);
  if (buffer_offset || count < io_buffer.data_view.byteLength)
    data = io_buffer.data_view.buffer.slice(buffer_offset, buffer_offset + count);
  else
    data = io_buffer.data_view.buffer;
  // frequently fails with:
  // Bail out! GLib:ERROR:../glib/giochannel.c:2362:g_io_channel_write_chars: assertion failed: (incomplete_len < 6)
  if (fd > 2) ret, len = channel.write_chars(Array.from(data), count);
  else if (fd == 2) console.warn((new TextDecoder()).decode(data));
  else if (fd == 1) console.log((new TextDecoder()).decode(data));
  return count;
};

// File
class FileStat {
  constructor(obj) { this.obj = obj; }
  get atimeMs() { return this.obj.get_access_date_time().to_unix_usec() / 1000; }
  get birthtimeMs() { return this.obj.get_creation_date_time().to_unix_usec() / 1000; }
  get blksize() { return Opal.nil; }
  get blocks() { return Opal.nil; }
  get ctimeMs() { return this.obj.get_creation_date_time().to_unix_usec() / 1000; }
  get dev() { return Opal.nil; }
  get gid() { return Opal.nil; }
  get ino() { return Opal.nil; }
  get mode() { return Opal.nil; }
  get mtimeMs() { return this.obj.get_modification_date_time().to_unix_usec() / 1000; }
  get nlink() { return Opal.nil; }
  get rdev() { return Opal.nil; }
  get size() { return this.obj.get_size(); }
  get uid() { return Opal.nil; }
  isBlockDevice() { return false; } // obj.get_file_type() == gio.FileType.SPECIAL; // maybe
  isCharacterDevice() { return false; } // obj.get_file_type() == gio.FileType.SPECIAL; } // maybe
  isDirectory() { return this.obj.get_file_type() == gio.FileType.DIRECTORY; }
  isFile() { return this.obj.get_file_type() == gio.FileType.REGULAR; }
  isFIFO() { return false; } // obj.get_file_type() == gio.FileType.SPECIAL; } // maybe
  isSocket() { return false; } // obj.get_file_type() == gio.FileType.SPECIAL; } // maybe
  isSymbolicLink() { return this.obj.get_file_type() == gio.FileType.SYMBOLIC_LINK; }
}

platform.file_chmod = (file_name, mode)=>glib.chmod(file_name.toString(), mode);
platform.file_chown = (_file_name, _uid, _gid)=>not_available("File.chown");
platform.file_fchmod = (_fd, _mode)=>not_available("File#chmod");
platform.file_fchown = (_fd, _uid, _gid)=>not_available("File#chown");
platform.file_flock = (_fd, _lock)=>not_available("File#flock");
platform.file_ftruncate = (_fd, _len)=>not_available("File#truncate");
platform.file_get_umask = ()=>not_available("File#umask");
platform.file_set_umask = ()=>not_available("File#umask");
platform.file_lchmod = (_file_name, _mode)=>not_available("File.lchmod");
platform.file_link = (_path_name, _new_path_name)=>not_available("File.link");
platform.file_lstat = (file_name)=>{
  let handle = gio.File.new_for_path(file_name.toString());
  try { return new FileStat(handle.query_info("*", gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null)); }
  catch (error) {
    Opal.Object.$const_get('Errno');
    let error_class = Opal.Errno.$const_get('ENOENT');
    Opal.Kernel.$raise(error_class.$new(error.message));
  }
}
platform.file_lutime = (_file_name, _atime, _mtime)=>not_available("File.lutime");
platform.file_mkfifo = (file_name, mode)=>{
  let status = glib.spawn_sync(null, ['mkfifo', '-m', mode.toString(8), file_name.toString()],
                               null, glib.SpawnFlags.DEFAULT, null);
  return status[0];
}
platform.file_readlink = (path_name)=>gio.File_read_link(path_name.toString());
platform.file_realpath = (path_name, _sep)=>{
  let handle = gio.File.new_for_path(path_name.toString()).resolve_relative_path(path_name.toString());
  return handle.get_path();
}
platform.file_rename = (old_name, new_name)=>glib.rename(old_name.toString(), new_name.toString());
platform.file_stat = (file_name)=>{
  let handle = gio.File.new_for_path(file_name.toString());
  try { return new FileStat(handle.query_info("*", gio.FileQueryInfoFlags.NONE, null)); }
  catch (error) {
    Opal.Object.$const_get('Errno');
    let error_class = Opal.Errno.$const_get('ENOENT');
    Opal.Kernel.$raise(error_class.$new(error.message));
  }
}
platform.file_symlink = (path_name, new_path_name)=>{
  gio.File.new_for_path(path_name.toString()).make_symbolic_link(new_path_name.toString());
}
platform.file_truncate = (_file_name, _len)=>not_available("File.truncate");;
platform.file_unlink = (file_name)=>glib.unlink(file_name.toString());
platform.file_utime = (_file_name, _atime, _mtime)=>not_available("File.utime");

// Dir
// As gjs cannot handle dirs with file descriptors, we need to emulate them.
// But this may lead to confusion, if dir fds are interchanged with file fds.
// Specifically with Dir.fchdir, but otherwise we would need to allocate a real fd,
// like above in Pipe.get_fd(), which is a bit overkill.
let directories = { __proto__: null, last: 0 }
platform.dir_chdir = (dir_name)=>glib.chdir(dir_name.toString());
platform.dir_chroot = (_dir_name)=>not_available("Dir.chroot");
platform.dir_close = (fd)=>{
  let dir = directories[fd];
  if (!dir) { return; }
  dir.enumerator.unref();
  dir.handle.unref();
  delete directories[fd];
}
platform.dir_home = ()=>glib.get_home_dir();
platform.dir_open = (dir_name)=>{
  dir_name = dir_name.toString();
  let handle = gio.File.new_for_path(dirname),
      enumerator = handle.enumerate_entries("*", gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null),
      fd = ++directories.last;
  directories[fd] = { handle: handle, enumerator: enumerator, eof: false, dot: false, dotdot: false, path: dir_name };
  return fd;
}
platform.dir_mkdir = (dir_name, mode)=>{
  dir_name = dir_name.toString();
  glib.mkdir(dir_name);
  glib.chmod(dir_name, mode);
}
platform.dir_next = (fd)=>{
  let dir = directories[fd];
  if (!dir) return;
  let entry, name;
  if (!dir.eof) entry = dir.enumerator.next_file(null);
  if (entry) {
    name = entry.get_name();
    entry.unref();
    return name;
  }
  else dir.eof = true;
  if (!dir.dot) {
    dir.dot = true;
    return '.';
  }
  if (!dir.dotdot) {
    dir.dotdot = true;
    return '..';
  }
}
platform.dir_path = (fd)=>directories[fd].handle.path;
platform.dir_rewind = (fd)=>{
  let dir = directories[fd];
  dir.enumerator.unref();
  dir.handle.unref();
  dir.handle = gio.File.new_for_path(dirname);
  dir.enumerator = dir.handle.enumerate_entries("", gio.FileQueryInfoFlags.NOFOLLOW_SYMLINKS, null)
  dir.eof = dir.dot = dir.dotdot = false;
}
platform.dir_unlink = (dir_name)=>glib.rmdir(dir_name.toString());
platform.dir_wd = ()=>glib.get_current_dir();

});}
