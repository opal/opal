//
// QuickJS
//
if ("quickjs" === Opal.platform.name) {
Opal.queue(async function() {

const platform = Opal.platform;

/* global os, std, scriptArgs */

// imports
// nothing to import

// Helpers
function not_available(fun) {
  platform.handle_unsupported_feature(fun + " is not available on quickjs");
}
// IO helper function to raise correct Ruby Error instead of platform specific error
function io_action(action, ...args) {
  try { return action(...args); }
  catch (error) {
    let code = error.code;
    if (platform.deno && !code) { code = error.message.split(':')[0]; }
    // Errno is autoloaded, to make sure it gets loaded eventually, must use const_get here
    if (Opal.Object.$const_get('Errno').$constants().indexOf(code) >= 0) {
      var error_class = Opal.Errno.$const_get(code);
      Opal.Kernel.$raise(error_class.$new(error.message));
    }
    Opal.Kernel.$raise(error);
  }
};

function raise_enoent(path) {
  Opal.Kernel.$raise(Opal.Object.$const_get('Errno').$const_get('ENOENT').$new(path + "not found"));
}

// RUBY_PLATFORM and some OS dependent switches
if (os.platform.includes("win")) {
  platform.ruby_platform = "opal mswin";
  platform.windows = true;
  platform.fs_casefold = true;
  platform.null_device = "NUL";
  platform.sysconfdir = Opal.nil;
  platform.tmpdir = ()=>std.getenv("TEMP");
} else {
  platform.ruby_platform = "opal " + os.platform;
  platform.windows = false;
  platform.fs_casefold = false
  platform.null_device = "/dev/null";
  platform.sysconfdir = "/etc"
  platform.tmpdir = ()=>"/tmp";
}

// Some platform info
platform.available_parallelism = ()=>1;
platform.machine = ()=>"unknown";
platform.nodename = ()=>"unknown";
platform.release = ()=>"unknown";
platform.sysname = ()=>os.platform;
platform.version = ()=>"unknown";
platform.path_sep = ':';

// Exit
platform.exit = std.exit;

// ARGV
platform.argv = scriptArgs.slice(1);

// ENV
platform.env_keys = ()=>Object.keys(std.getenviron());
platform.env_get = (key)=>std.getenv(key.toString());
platform.env_del = (key)=>std.unsetenv(key.toString());
platform.env_has = (key)=>{ return std.getenv(key.toString()) == null ? false : true };
platform.env_set = (key, val)=>std.setenv(key.toString(), val.toString());

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
platform.process_sig_list = (new Map()).set("EXIT",0).set("HUP",1).set("INT",2).set("ILL",4).set("TRAP",5).set("ABRT",6)
                                    .set("IOT",6).set("FPE",8).set("KILL",9).set("BUS",7).set("SEGV",11).set("SYS",31)
                                    .set("PIPE",13).set("ALRM",14).set("TERM",15).set("URG",23).set("STOP",19)
                                    .set("TSTP",20).set("CONT",18).set("CHLD",17).set("CLD",17).set("TTIN",21)
                                    .set("TTOU",22).set("IO",29).set("XCPU",24).set("XFSZ",25).set("VTALRM",26)
                                    .set("PROF",27).set("WINCH",28).set("USR1",10).set("USR2",12).set("PWR",30)
                                    .set("POLL",29);
platform.process_kill = (pid, signal)=>os.kill(pid, 'SIG' + signal.toString());
platform.process_pid = os.getpid;
platform.process_ppid = ()=>not_available("Proc.ppid");
platform.process_set_title = (_title)=>not_available("Proc.setproctitle");
platform.process_is_primary = ()=>not_available("Kernel.fork");
platform.process_is_worker = ()=>not_available("Kernel.fork");
platform.process_fork = ()=>not_available("Kernel.fork");
platform.process_worker_pid = (_worker)=>not_available("Kernel.fork");
platform.process_exec = (cmd)=>os.exec([cmd.toString()], { block: true, usePath: true });
platform.process_spawn = function() {
  for(let i = 0; i < arguments.length; i++) {
    if (arguments[i] instanceof String) arguments[i] = arguments[i].toString();
  }
  return os.exec(arguments, { block: true });
}

// IO Pipe
platform.io_pipe = os.pipe;
platform.io_pipe_eof = (fd)=>{
  let file = std.fdopen(fd), eof = file.eof();
  file.close();
  return eof;
}

let handles = { __proto__: null };

// IO popen
// unfortunately std.popen is unreliable and hangs when closing the handle
platform.io_popen = function(cmd, args, _options) {
  not_available("IO.popen");
  // if (args) cmd = cmd + ' ' + args.join(' ');
  // let handle = std.popen(cmd.toString(), "rw"), fd;
  // if (!handle) return [Opal.nil, Opal.nil];
  // fd = handle.fileno();
  // handles[fd] = handle;
  // return [fd, 0];
}

// IO
platform.io_close = (fd)=>{
  let handle = handles[fd];
  if (!handle) return;
  delete handles[fd];
  handle.close();
}
platform.io_fdatasync = (fd)=>{ if (handles[fd]) handles[fd].flush(); }
platform.io_fstat = (_fd)=>not_available("File#fstat");
platform.io_fsync = (fd)=>{ if (handles[fd]) handles[fd].flush(); }
platform.io_ioctl = (_cmd, _arg)=>not_available("IO#ioctl");
platform.io_open = (fd, flags)=>{
  if (fd < 3) return true;
  let handle = handles[fd];
  if (handle) return false;
  handle = std.fdopen(fd, flags);
  handles[fd] = handle;
  return false;
};
platform.io_open_path = function(path_name, flags, perm) {
  path_name = path_name.toString();
  let handle = std.open(path_name, flags),
      fd = handle.fileno();
  handles[fd] = handle;
  return fd;
}
platform.io_read = function(fd, io_buffer, buffer_offset, pos, count) {
  let handle = (fd == 0) ? std.in : handles[fd], len;
  if (pos) handle.seek(pos, std.SEEK_SET);
  len = handle.read(io_buffer.data_view.buffer, buffer_offset, count);
  return len;
};
platform.io_write = function(fd, io_buffer, buffer_offset, pos, count) {
  let handle;
  if (fd == 1) handle = std.out;
  else if (fd == 2) handle = std.err;
  else handle = handles[fd];
  if (pos) handle.seek(pos, std.SEEK_SET);
  handle.write(io_buffer.data_view.buffer, buffer_offset, count);
  return count;
};

// File
class FileStat {
  constructor(obj) { this.obj = obj; }
  get atimeMs() { return this.obj.atime; }
  get birthtimeMs() { return this.obj.ctime; }
  get blksize() { return Opal.nil; }
  get blocks() { return this.obj.blocks; }
  get ctimeMs() { return this.obj.ctime; }
  get dev() { return this.obj.dev; }
  get gid() { return this.obj.gid; }
  get ino() { return this.obj.ino; }
  get mode() { return this.obj.mode; }
  get mtimeMs() { return this.obj.mtime; }
  get nlink() { return this.obj.nlink; }
  get rdev() { return this.obj.rdev; }
  get size() { return this.obj.size; }
  get uid() { return this.obj.uid; }
  isBlockDevice() { return (this.obj.mode & os.S_IFBLK) == os.S_IFBLK; }
  isCharacterDevice() { return (this.obj.mode & os.S_IFCHR) == os.S_IFCHR; }
  isDirectory() { return (this.obj.mode & os.S_IFDIR) == os.S_IFDIR; }
  isFile() {
    return (this.obj.mode & (os.S_IFBLK | os.S_IFCHR | os.S_IFDIR | os.S_IFIFO | os.S_IFSOCK | os.S_IFLNK)) == 0;
  }
  isFIFO() { return (this.obj.mode & os.S_IFIFO) == os.S_IFIFO; }
  isSocket() { return (this.obj.mode & os.S_IFSOCK) == os.S_IFSOCK; }
  isSymbolicLink() { return (this.obj.mode & os.S_IFLNK) == os.S_IFLNK; }
}

platform.file_chmod = (_file_name, _mode)=>not_available("File.chmod");
platform.file_chown = (_file_name, _uid, _gid)=>not_available("File.chown");
platform.file_fchmod = (_fd, _mode)=>not_available("File#chmod");
platform.file_fchown = (_fd, _uid, _gid)=>not_available("File#chown");
platform.file_flock = (_fd, _lock)=>not_available("File#flock");
platform.file_ftruncate = (_fd, _len)=>not_available("File#truncate");
platform.file_get_umask = ()=>not_available("File.umask");
platform.file_set_umask = ()=>not_available("File.umask");
platform.file_lchmod = (_file_name, _mode)=>not_available("File.lchmod");
platform.file_link = (_path_name, _new_path_name)=>not_available("File.link");
platform.file_lstat = (file_name)=>{
  let stat = os.lstat(file_name.toString())[0];
  if (!stat) raise_enoent(file_name);
  return new FileStat(stat);
}
platform.file_lutime = (_file_name, _atime, _mtime)=>not_available("File.lutime");
platform.file_mkfifo = (file_name, mode)=>{
  if (platform.windows) not_available("On Windows File.mkfifo");
  return os.exec(['mkfifo', '-m', mode.toString(8), file_name.toString()], { block: true, usePath: true });
}
platform.file_readlink = (path_name)=>os.readlink(path_name.toString());
platform.file_realpath = (path_name, _sep)=>os.realpath(path_name.toString())[0];
platform.file_rename = (old_name, new_name)=>os.rename(old_name.toString(), new_name.toString());
platform.file_stat = (file_name)=>{
  let stat = os.stat(file_name.toString())[0];
  if (!stat) raise_enoent(file_name);
  return new FileStat(stat);
}
platform.file_symlink = (path_name, new_path_name)=>os.symlink(path_name.toString(), new_path_name.toString());
platform.file_truncate = (_file_name, _len)=>not_available("File.truncate");
platform.file_unlink = (file_name)=>os.remove(file_name.toString());
platform.file_utime = (file_name, atime, mtime)=>os.utimes(file_name.toString(), atime, mtime);

// Dir
// As quickjs cannot handle dirs with file descriptors, we need to emulate them.
// But this may lead to confusion, if dir fds are interchanged with file fds.
// Specifically with Dir.fchdir, but otherwise we would need to allocate a real fd,
// like above in Pipe.get_fd(), which is a bit overkill.
let directories = { __proto__: null, last: 0 }
platform.dir_chdir = (dir_name)=>os.chdir(dir_name.toString());
platform.dir_chroot = (_dir_name)=>not_available("Dir.chroot");
platform.dir_close = (fd)=>{
  let dir = directories[fd];
  if (!dir) { return; }
  delete directories[fd];
}
platform.dir_home = ()=>platform.env_get("HOME");
platform.dir_open = (dir_name)=>{
  let fd = ++directories.last;
  directories[fd] = { path: dir_name.toString(), eof: false, dot: false, dotdot: false, pos: 0 };
  return fd;
}
platform.dir_mkdir = (dir_name, mode)=>os.mkdir(dir_name.toString(), mode );
platform.dir_next = (fd)=>{
  let dir = directories[fd];
  if (!dir) return;
  let entries, entry, err;
  if (!dir.eof) {
    entries, err = os.readdir(dir.path);
    entry = entries[dir.pos++];
  }
  if (entry) return entry;
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
platform.dir_path = (fd)=>directories[fd].path;
platform.dir_rewind = (fd)=>{
  let dir = directories[fd];
  dir.pos = 0;
  dir.eof = dir.dot = dir.dotdot = false;
}
platform.dir_unlink = (dir_name)=>os.remove(dir_name.toString());
platform.dir_wd = ()=>os.getcwd()[0];

});}
