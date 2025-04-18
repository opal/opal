//
// Browsers, Chrome, Firefox, Safari and others
//

if (Opal.platform.is_browser) {
Opal.queue(async function() {

// used vars
const platform = Opal.platform;
let fd_paths = { __proto__: null, fd: 3 },
    text_decoder = new TextDecoder('utf8'),
    vsvfs;

// Helpers
// get the Virtual File System if it has been loaded
function get_vfs() {
  if (vsvfs) return vsvfs;
  if (Opal.VSVFS) {
    vsvfs = new Opal.VSVFS();
    vsvfs.mkdir(platform.sysconfdir);
    vsvfs.mkdir(platform.tmpdir());
    return vsvfs;
  }
}
// help to present the correct message for a missing feature
function not_available(fun) {
  platform.handle_unsupported_feature(fun + " is not available on " + platform.name);
  return Opal.nil;
}
function raise_errno(errno, error) {
    // Errno is autoloaded, to make sure it gets loaded eventually, must use const_get here
    if (Opal.Object.$const_get('Errno').$constants().indexOf(errno) >= 0) {
      let error_class = Opal.Errno.$const_get(errno);
      Opal.Kernel.$raise(error_class.$new());
    }
    if (error) Opal.Kernel.$raise(error);
}
// IO helper function to raise correct Ruby Error instead of platform specific error
function io_action(that, action, ...args) {
  try { return action.apply(that, args); }
  catch (error) { raise_errno(error.message, error); }
};

// RUBY_PLATFORM and some OS dependent switches
if (navigator.userAgent.includes("Windows")) {
  platform.ruby_platform = "opal mswin";
  platform.windows = true;
  platform.fs_casefold = true;
  platform.null_device = "NUL";
  platform.sysconfdir = Opal.nil;
  platform.alt_sep = "\\";
  platform.path_sep = ";";
} else {
  platform.ruby_platform = (navigator.userAgent.includes("Linux")) ? "opal linux" : "opal";
  platform.windows = false;
  platform.fs_casefold = false;
  platform.null_device = "/dev/null";
  platform.sysconfdir = "/etc"
  platform.path_sep = ":";
}


// Some platform info
platform.available_parallelism = ()=>1;
platform.machine = ()=>"unknown";
platform.nodename = ()=>"unknown";
platform.release = ()=>"unknown";
platform.sysname = ()=>platform.name;
platform.tmpdir = ()=>"/tmp";
platform.version = ()=>"unknown";

// Exit
platform.exit = function(status) {
  if (window.OPAL_EXIT_CODE === "noexit") {
    // Special support for CDP runners, chrome and firefox.
    // The first call to platform.exit should save an exit code.
    // Then we send an event to Chrome CDP Interface that we are finished
    // All further invocations must be ignored.
    window.OPAL_EXIT_CODE = status;
    window.alert("opalheadlessbrowserexit");
  } else if (Opal.gvars.DEBUG) {
    console.log('Exited with status ' + status) ;
  }
};

// ARGV
platform.argv = [];

// ENV emulation
const env = { __proto__: null };
platform.env_keys = ()=>Object.keys(env);
platform.env_get = (key)=>env[key.toString()];
platform.env_del = (key)=>{ delete env[key.toString()]; };
platform.env_has = (key)=>env[key.toString()] != null;
platform.env_set = (key, value)=>env[key.toString()]=value.toString();

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
platform.process_sig_list = new Map();
platform.process_kill = ()=>not_available("Proc.kill");
platform.process_pid = ()=>not_available("Proc.pid");
platform.process_ppid = ()=>not_available("Proc.ppid");
platform.process_set_title = (_title)=>not_available("Proc.setproctitle");
platform.process_is_primary = ()=>not_available("#fork");
platform.process_is_worker = ()=>not_available("#fork");
platform.process_fork = ()=>not_available("#fork");
platform.process_worker_pid = (_worker)=>not_available("#fork");
platform.process_exec = (_cmd)=>not_available("#`");
platform.process_spawn = ()=>not_available("#system");

// IO.pipe
platform.io_pipe = ()=>not_available("IO.pipe");
platform.io_pipe_eof = ()=>not_available("IO#eof for pipes");

// IO.popen
platform.io_popen = ()=>not_available("IO.popen");

// IO
platform.io_close = (fd)=>{ if (fd > 2) { delete fd_paths[fd]; }}
platform.io_fdatasync = (_fd)=>not_available("IO#fdatasync");
platform.io_fstat = (fd)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.stat, fd_paths[fd]?.path);
  return not_available("IO#fstat");
}
platform.io_fsync = (_fd)=>not_available("IO#fsync");
platform.io_ioctl = (_cmd, _arg)=>not_available("IO#ioctl");
platform.io_open = (_fd)=>false;
platform.io_open_path = (path_name, flags, _perm)=>{
  let vfs = get_vfs(), fd, stat, created = false;
  if (vfs) {
    path_name = vfs.absolute(path_name.toString());
    try { stat = vfs.stat(path_name); }
    catch (e) {
      if (e.message == "ENOENT" && (flags & 64)) {
        io_action(vfs, vfs.write, path_name, new Uint8Array(0), 0, 0); // CREAT
        created = true;
      } else raise_errno(e.message, e);
    }
    if (stat) {
      if (stat.isDirectory()) raise_errno("EISDIR");
      if (stat.isFile && (flags & 128)) raise_errno("EEXIST"); // EXCL
    }
    if (!created && (flags & 512)) io_action(vfs, vfs.truncate, path_name, 0); // TRUNC
    fd = fd_paths.fd++;
    fd_paths[fd] = { __proto__: null, path: path_name };
    return fd;
  }
  return not_available("IO for fd > 2");
}
platform.io_read = (fd, io_buffer, buffer_offset, pos, count)=>{
  let vfs = get_vfs(), u8a;
  if (vfs) {
    u8a = new Uint8Array(io_buffer.data_view.buffer, buffer_offset, count);
    return io_action(vfs, vfs.read, fd_paths[fd]?.path, u8a, pos, count);
  }
  return not_available("IO#read");
}
platform.io_write = (fd, io_buffer, buffer_offset, pos, count)=>{
  // if (typeof(window.OPAL_CDP_SHARED_SECRET) !== "undefined") {
  //   // support for Cli Runners
  //   platform.fs.writeFileSync = function(path, data) {
  //     var http = new XMLHttpRequest();
  //     http.open("POST", "/File.write");
  //     http.setRequestHeader("Content-Type", "application/json");
  //     // Failure is not an option
  //     http.send(JSON.stringify({filename: path, data: data, secret: window.OPAL_CDP_SHARED_SECRET}));
  //   };
  // }
  let vfs = get_vfs(), u8a;
  if (fd > 2) {
    if (vfs) {
      u8a = new Uint8Array(io_buffer.data_view.buffer, buffer_offset, count);
      return io_action(vfs, vfs.write, fd_paths[fd]?.path, u8a, pos, count);
    }
    return not_available("IO for fd > 2");
  }
  let data;
  if (buffer_offset || count < io_buffer.data_view.byteLength)
    data = io_buffer.data_view.buffer.slice(buffer_offset, buffer_offset + count);
  else
    data = io_buffer.data_view.buffer;
  if (fd == 1) console.log(text_decoder.decode(data));
  else if (fd == 2) console.warn(text_decoder.decode(data));
  return count;
};

// File
platform.file_chmod = (_file_name, _mode)=>not_available("File.chmod");
platform.file_chown = (_file_name, _uid, _gid)=>not_available("File.chown");
platform.file_fchmod = (_fd, _mode)=>not_available("File#chmod");
platform.file_fchown = (_fd, _uid, _gid)=>not_available("File#chown");
platform.file_flock = (_fd, _lock)=>not_available("File#flock");
platform.file_ftruncate = (fd, len)=>{
  let vfs = get_vfs();
  if (vfs) {
    io_action(vfs, vfs.truncate, fd_paths[fd]?.path, len);
    return Opal.nil;
  }
  not_available("File#truncate");
}
platform.file_get_umask = ()=>not_available("File.umask");
platform.file_set_umask = ()=>not_available("File.umask");
platform.file_lchmod = (_file_name, _mode)=>not_available("File.lchmod");
platform.file_link = (_path_name, _new_path_name)=>not_available("File.link");
platform.file_lstat = (file_name)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.stat, file_name.toString());
  return not_available("File.lstat");
}
platform.file_lutime = (_file_name, _atime, _mtime)=>not_available("File.lutime");
platform.file_mkfifo = (_file_name, _mode)=>not_available("File.mkfifo");
platform.file_readlink = (_path_name)=>not_available("File.readlink");
platform.file_realpath = (path_name, _sep)=>path_name.toString();
platform.file_rename = (_old_name, _new_name)=>not_available("File.rename");
platform.file_stat = (file_name)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.stat, file_name.toString());
  return not_available("File.stat");
}
platform.file_symlink = (_path_name, _new_path_name)=>not_available("File.symlink");
platform.file_truncate = (file_name, len)=>{
  let vfs = get_vfs();
  if (vfs) {
    io_action(vfs, vfs.truncate, file_name.toString(), len);
    return Opal.nil;
  }
  return not_available("File.truncate");
}
platform.file_unlink = (file_name)=>{
  let vfs = get_vfs();
  if (vfs) {
    io_action(vfs, vfs.rm, file_name.toString());
    return Opal.nil;
  }
  return not_available("File.unlink");
}
platform.file_utime = (_file_name, _atime, _mtime)=>not_available("File.utime");

// Dir
platform.dir_chdir = (dir_name)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.chdir, dir_name.toString());
  return not_available("Dir.chdir");
}
platform.dir_chroot = (_dir_name)=>not_available("Dir.chroot");
platform.dir_close = platform.io_close;
platform.dir_home = ()=>'/';
platform.dir_open = (dir_name)=>{
  let vfs = get_vfs(), fd, stat;
  if (!vfs) return not_available("Dir.new");
  dir_name = vfs.absolute(dir_name.toString());
  stat = io_action(vfs, vfs.stat, dir_name);
  if (!stat.isDirectory()) raise_errno("ENOTDIR");
  fd = fd_paths.fd++;
  fd_paths[fd] = { __proto__: null, dir: true, path: dir_name, eof: false, dot: false, dotdot: false };
  return fd;
}
platform.dir_mkdir = (dir_name, _mode)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.mkdir, dir_name.toString());
  return not_available("Dir.mkdir");
}
platform.dir_next = (fd)=>{
  let vfs = get_vfs(), dir, entry;
  if (!vfs) return not_available("Dir#next");
  dir = fd_paths[fd];
  if (!dir.dir) raise_errno("ENOTDIR");
  if (!dir.entries) dir.entries = io_action(vfs, vfs.ls, dir.path);
  if (dir.ce == null) dir.ce = 0;
  entry = dir.entries[dir.ce++];
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
platform.dir_path = (fd)=>{
  let vfs = get_vfs(), dir;
  if (!vfs) return not_available("Dir#path")
  dir = fd_paths[fd];
  if (!dir.dir) raise_errno("ENOTDIR");
  return dir.path;
}
platform.dir_rewind = (fd)=>{
  let vfs = get_vfs();
  if (!vfs) return not_available("Dir#rewind");
  let dir = fd_paths[fd];
  dir.eof = dir.dot = dir.dotdot = false;
}
platform.dir_unlink = (dir_name)=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.rmdir, dir_name.toString());
  return not_available("Dir.unlink");
}
platform.dir_wd = ()=>{
  let vfs = get_vfs();
  if (vfs) return io_action(vfs, vfs.cwd);
  return not_available('/');
}

});}
