//
// Node and compatible engines, Bun, Deno, GraalNodeJs
//

// Note to self: https://nodejs.org/api/tty.html

if (["bun", "deno", "graalnodejs", "node"].includes(Opal.platform.name)) {
Opal.queue(async function() {

const platform = Opal.platform;

// imports
const child_process = await import("node:child_process");
// const cluster = await import("node:cluster");
const fs = await import("node:fs");
const os = await import("node:os");
const path = await import("node:path");
const process = await import("node:process");

// RUBY_PLATFORM and some OS dependent switches
if (os.platform().includes("win")) {
  platform.ruby_platform = "opal mswin";
  platform.windows = true;
  platform.fs_casefold = true;
  platform.null_device = "NUL";
  platform.sysconfdir = Opal.nil;
} else {
  platform.ruby_platform = (os.platform().includes("linux")) ? "opal linux" : "opal";
  platform.windows = false;
  platform.fs_casefold = false
  platform.null_device = "/dev/null";
  platform.sysconfdir = "/etc"
}

// Some platform info
platform.available_parallelism = os.availableParallelism;
platform.machine = os.machine;
platform.nodename = os.hostname;
platform.release = os.release;
platform.sysname = os.type;
platform.tmpdir = os.tmpdir;
platform.version = os.version;

// Exit
platform.exit = process.exit;

// ARGV
platform.argv = process.argv.slice(2)

// ENV
platform.env_keys = ()=>Object.keys(process.env);
platform.env_get = (key)=>process.env[key.toString()];
platform.env_del = (key)=>{ delete process.env[key.toString()]; };
platform.env_has = (key)=>process.env.hasOwnProperty(key.toString());
platform.env_set = (key, value)=> {
  key = key.toString();
  value = value.toString();
  if (key === "TZ") {
    // Node understands only timezones in the form of "TZ identifiers" like in the Table at
    // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. To make setting TZ work
    // when given in Ruby style "PDT8:00:00" it must be converted to "Etc/GMT+8". TZ can be set to "PDT8:00:00",
    // but node will not change its timezone, "Etc/GMT+8" must be used in this case to have an effect on eg.
    // new Date(). This applies to other zones too, of course, but just for specs, lets be happy with a few.
    if (value.includes(':')) {
      let val = value.slice(0,4);
      switch (val) {
        case "PDT8": value = "Etc/GMT+8"; break;
        case "CST6": value = "Etc/GMT+6"; break;
      }
    }
    // In case a invalid format is given, UTC is used. Valid formats:
    if (!(
      value.match(/^\w+\/\w+$/) ||       // America/Ensenada
      value.match(/^Etc\/GMT[-+]\d$/) || // Etc/GMT+7
      value.match(/^\w+$/)               // Japan
    )) value = "UTC";
  }
  return process.env[key] = value;
};

// Process
// TODO: move -1 function to common
let proc_umask = 18;
platform.proc_getegid = (typeof process.getegid === "function") ? process.getegid : ()=>-1;
platform.proc_setegid = (typeof process.setegid === "function") ? process.setegid : ()=>-1;
platform.proc_geteuid = (typeof process.geteuid === "function") ? process.geteuid : ()=>-1;
platform.proc_seteuid = (typeof process.seteuid === "function") ? process.seteuid : ()=>-1;
platform.proc_getgid = (typeof process.getgid === "function") ? process.getgid : ()=>-1;
platform.proc_setgid = (typeof process.setgid === "function") ? process.setgid : ()=>-1;
platform.proc_getgroups = (typeof process.getgroups === "function") ? process.getgroups : ()=>[];
platform.proc_getuid = (typeof process.getuid === "function") ? process.getuid : ()=>-1;
platform.proc_setuid = (typeof process.setuid === "function") ? process.setuid : ()=>-1;
platform.proc_get_umask = ()=>proc_umask; // process.umask() without args in node is deprecated, lets emulate
platform.proc_set_umask = function(umask) {
  proc_umask = umask;
  return process.umask(umask);
}
platform.proc_kill = process.kill;
platform.proc_pid = ()=>process.pid;
platform.proc_ppid = ()=>process.ppid;
platform.proc_set_title = (title)=> { process.title = title.toString(); }
platform.proc_is_primary = ()=>cluster.isPrimary;
platform.proc_is_worker = ()=>cluster.isWorker;
platform.proc_fork = ()=>cluster.fork();
platform.proc_worker_pid = (worker)=>worker.process.pid;
platform.proc_exec = (cmd)=>child_process.execSync(cmd.toString());
platform.proc_spawn = function() {
  for(let i = 0; i < arguments.length; i++) {
    if (arguments[i] instanceof String) arguments[i] = arguments[i].toString();
  }
  return child_process.spawnSync.apply(null, arguments);
}

// IO Pipe
// In process pipe, because Nodejs does not support real pipes, so lets emulate them.
// For the Future: maybe can use unix sockets/named pipes for real IPC with cluster.fork() here.
platform.pipes = { __proto__: null };

class Pipe {
  static get_fd() {
    // Allocate a real FD, but don't actually use it for reading/writing.
    // It is still useful for stat or others though.
    let sep = path.sep,
        tmpdir = fs.mkdtempSync(os.tmpdir() + sep + "opal-pipe-emu-");
    return [fs.openSync(tmpdir + sep + "pipe", "wx+"), tmpdir];
  }
  constructor()  {
    this.data_view = new DataView(new ArrayBuffer(0));
    this.write_pos = 0;
    [this.rfd, this.rtd] = Pipe.get_fd();
    [this.wfd, this.wtd] = Pipe.get_fd();
    this.rclosed = false;
    this.wclosed = false;
  }
  read(io_buffer, buffer_offset, count) {
    if (this.write_pos === 0) return 0; // nothing to read
    if (count == null) count = Infinity;
    let dv = io_buffer.data_view, i = 0,
        max_read = Math.min(this.write_pos, dv.byteLength - buffer_offset, count);
    for (; i < max_read; i++) {
      dv.setUint8(buffer_offset++, this.data_view.getUint8(i));
    }
    let buffer = this.data_view.buffer.slice(max_read);
    this.data_view = new DataView(buffer);
    this.write_pos -= max_read;
    return max_read;
  }
  write(io_buffer, buffer_offset, count) {
    if (count == null) count = Infinity;
    let dv = io_buffer.data_view, i = 0,
        max_write = Math.min(count, dv.byteLength - buffer_offset);
    if (max_write === 0) return 0; // nothing to write
    if ((this.write_pos + max_write) > this.data_view.byteLength) {
      let buffer = this.data_view.buffer.transfer(this.data_view.byteLength + max_write);
      this.data_view = new DataView(buffer)
    }
    for (; i < max_write; i++) {
      this.data_view.setUint8(this.write_pos++, dv.getUint8(buffer_offset++));
    }
    return max_write;
  }
  close(fd) {
    if (fd === this.rfd && !this.rclosed) {
      this.rclosed = true;
      try { fs.closeSync(fd) } catch (e) {}
      fs.rmdirSync(this.rtd, { recursive: true });
    } else if (!this.wclosed) {
      this.wclosed = true;
      try { fs.closeSync(fd) } catch (e) {}
      fs.rmdirSync(this.wtd, { recursive: true });
    }
  }
  eof(fd) {
    if (fd === this.rfd) { return this.data_view.byteLength === 0; }
    return false;
  }
  get read_fd() { return this.rfd; }
  get write_fd() { return this.wfd; }
}

platform.io_pipe = function() {
  let pp = new Pipe();
  platform.pipes[pp.read_fd] = pp;
  platform.pipes[pp.write_fd] = pp;
  return [pp.read_fd, pp.write_fd];
}
platform.io_pipe_eof = function(fd) {
  return platform.pipes[fd].eof(fd);
}

// IO spawn (used by IO::popen)
class SpawnPipe {
  constructor(buff_size, cmd, args, options)  {
    this.data_view = new DataView(new ArrayBuffer(buff_size));
    this.write_pos = 0;
    this.closed = false;
    [this.pfd, this.ptd] = Pipe.get_fd();
    this.tencoder = new TextEncoder();
    let pipe = this;
    function process_data(data) {
      let uint8ary = pipe.tencoder.encode(data.toString('utf8')),
          i = 0;
      if ((pipe.data_view.byte_length - pipe.write_pos) < uint8ary.byteLength) {
        let buffer = pipe.data_view.buffer.transfer(pipe.write_pos + uint8ary.byteLength)
        pipe.data_view = new DataView(buffer);
      }
      for (; i < uint8ary.byteLength;) {
        pipe.data_view.setUint8(pipe.write_pos++, uint8ary[i++]);
      }
    }
    this.chpr = child_process.spawn(cmd, args, options);
    if (this.chpr.stdout) {
      this.chpr.stdout.on('data', process_data);
      this.chpr.stdout.on('end', process_data);
    }
    this.chpr.on('exit', function(_code) { pipe.closed = true; });
  }
  read(io_buffer, buffer_offset, count) {
    if (this.write_pos === 0) return 0; // nothing to read
    if (count == null) count = Infinity;
    let dv = io_buffer.data_view, i = 0,
        max_read = Math.min(this.write_pos, dv.byteLength - buffer_offset, count);
    for (; i < max_read; i++) {
      dv.setUint8(buffer_offset++, this.data_view.getUint8(i));
    }
    let buffer = this.data_view.buffer.slice(max_read);
    this.data_view = new DataView(buffer);
    this.write_pos -= max_read;
    return max_read;
  }
  write(io_buffer, buffer_offset, count) {
    if (this.closed) return -1;
    if (count == null) count = Infinity;
    let uint8ary = new Uint8Array(io_buffer.data_view.buffer),
        max_write = Math.min(count, uint8ary.byteLength - buffer_offset);
    if (max_write === 0) return 0; // nothing to write
    if (buffer_offset > 0 || (buffer_offset + max_write) < uint8ary.byteLength)
      uint8ary = new Uint8Array(uint8ary.buffer.slice(buffer_offset, buffer_offset + max_write));
    this.chpr.stdin.write(uint8ary);
    return max_write;
  }
  close(_fd) {
    if (!this.closed) {
      this.closed = true;
      try { this.chpr.kill(); }
      catch {}
      try { fs.closeSync(this.pfd) } catch (e) {}
      fs.rmdirSync(this.ptd, { recursive: true });
    }
  }
  get fd() { return this.pfd; }
  get pid() { return this.chpr.pid; }
}

platform.io_spawn = function(cmd, args, options) {
  let pp = new SpawnPipe(1024, cmd.toString(), args, options);
  platform.pipes[pp.fd] = pp;
  return [pp.fd, pp.pid];
}

// IO

function emulate_ctx(c, t, x , path_name, perm) {
  if (c && x) Opal.Kernel.$raise(Opal.Errno.EEXIST, "file already exists, open '" + path_name + "'");
  if (c && !fs.existsSync(path_name)) fs.writeFileSync(path_name, '', { mode: perm });
  if (!c || x) platform.file_stat(path_name); // will raise if file doesn't exist
  if (t) platform.file_truncate(path_name, 0);
}
function emulated_flags_to_mode(flags, path_name, perm) {
  const o = Opal.File.Constants;
  let a = flags & o.APPEND,
      c = flags & o.CREAT,
      rw = flags & o.RDWR,
      t = flags & o.TRUNC,
      w = flags & o.WRONLY,
      x = flags & o.EXCL;
  if (rw && w) Opal.Kernel.$raise(Opal.IOError, "illegal mode");
  emulate_ctx(c, t, x, path_name, perm);
  // now choose the closest mode, that doesn't mess up the file
  if ( a && !rw &&  w)  return "a";
  if ( a &&  rw && !w)  return "a+";
  if (!a && (rw ||  w)) return "r+";
  if (!a && !rw && !w)  return "r";
}
function flags_to_mode(flags) {
  const o = Opal.File.Constants;
  if (flags === (o.APPEND | o.CREAT | o.EXCL | o.RDWR))   return "ax+";
  if (flags === (o.APPEND | o.CREAT | o.RDWR))            return "a+";
  if (flags === (o.APPEND | o.CREAT | o.EXCL | o.WRONLY)) return "ax";
  if (flags === (o.APPEND | o.CREAT | o.WRONLY))          return "a";
  if (flags === (o.RDWR   | o.CREAT | o.EXCL | o.TRUNC))  return "wx+";
  if (flags === (o.RDWR   | o.CREAT | o.TRUNC))           return "w+";
  if (flags === (o.WRONLY | o.CREAT | o.EXCL | o.TRUNC))  return "wx";
  if (flags === (o.WRONLY | o.CREAT | o.TRUNC))           return "w";
  if (flags === o.RDWR)   return "r+";
  if (flags === o.RDONLY) return "r";
}

platform.io_close = function(fd) {
  if (fd < 3) return; // closing fd < 3 will confuse node, so we don't do it
  if (platform.pipes[fd]) {
    platform.pipes[fd].close(fd);
    delete platform.pipes[fd];
  } else {
    // Guard against double close from shared fd.
    // This can happen e.g. via ::IO#reopen.
    try { fs.closeSync(fd); } catch (e) {}
  }
}
platform.io_fdatasync = function(fd) { if (fd > 2) platform.io_action(fs.fdatasyncSync, fd); }
platform.io_fstat = function(fd) { return platform.io_action(fs.fstatSync, fd); }
platform.io_fsync = function(fd) { if (fd > 2) platform.io_action(fs.fsyncSync, fd); }
platform.io_ioctl = function(_cmd, _arg) {
  Opal.Kernel.$raise(Opal.NotImplementedError, 'IO.ioctl is not available on nodejs and compatible platforms');
}
platform.io_open = (fd)=>{ return fd < 3 ? true : false };
platform.io_open_path = function(path_name, flags, perm) {
  const o = Opal.File.Constants;
  path_name = path_name.toString();
  let mode = flags_to_mode(flags);
  if (!mode) mode = emulated_flags_to_mode(flags, path_name, perm);
  return platform.io_action(fs.openSync, path_name, mode, perm);
}
platform.io_read = function(fd, io_buffer, buffer_offset, pos, count) {
  let pp = platform.pipes[fd];
  if (pp) return pp.read(io_buffer, buffer_offset, count);
  return platform.io_action(fs.readSync, fd, io_buffer.data_view, buffer_offset, count, pos);
};
platform.io_write = function(fd, io_buffer, buffer_offset, pos, count) {
  let data = io_buffer.data_view;
  // Also in theory its possible to use fs.writeSync for std*, but in reality that works only half the time and
  // causes problems.
  if (fd === 1) { process.stdout.write(data, 'utf8', ()=>{}); return data.byteLength; }
  else if (fd === 2) { process.stderr.write(data, 'utf8', ()=>{}); return data.byteLength; }
  let pp = platform.pipes[fd];
  if(pp) return pp.write(io_buffer, buffer_offset, count);
  return platform.io_action(fs.writeSync, fd, data, buffer_offset, count, pos);
};

// File
platform.sep = path.sep;
platform.file_chmod = function(file_name, mode) { platform.io_action(fs.chmodSync, file_name.toString(), mode); }
platform.file_chown = function(file_name, uid, gid) {
  platform.io_action(fs.chownSync, file_name.toString(), uid, gid);
}
platform.file_fchmod = function(fd, mode) { platform.io_action(fs.fchmodSync, fd, mode); }
platform.file_fchown = function(fd, uid, gid) { platform.io_action(fs.fchownSync, fd, uid, gid); }
platform.file_flock = function(_fd, _lock) {
  Opal.Kernel.$raise(Opal.NotImplementedError, 'File#flock is not available on nodejs and compatible platforms');
}
platform.file_ftruncate = function(fd, len) { platform.io_action(fs.ftruncateSync, fd, len); }
platform.file_futimes = function(fd, atime, mtime) { platform.io_action(fs.futimesSync, fd, atime, mtime); }
platform.file_is_absolute_path = function(file_name) {
  return platform.io_action(path.isAbsolute, file_name.toString());
}
platform.file_lchmod = function(_file_name, _mode) {
  Opal.Kernel.$raise(Opal.NotImplementedError, 'File#lchmod is not available on nodejs and compatible platforms');
}
platform.file_link = function(path_name, new_path_name) {
  platform.io_action(fs.linkSync, path_name.toString(), new_path_name.toString());
}
platform.file_lstat = function(file_name) { return platform.io_action(fs.lstatSync, file_name.toString()); }
platform.file_lutime = function(file_name, atime, mtime) {
  platform.io_action(fs.lutimesSync, file_name.toString(), atime, mtime);
}
platform.file_mkfifo = function(file_name, mode) {
  if (platform.windows) {
    Opal.Kernel.$raise(Opal.NotImplementedError,
                       'File#mkfifo is not available on nodejs and compatible platforms on Windows');
  }
  let res = child_process.spawnSync('mkfifo', ['-m', mode.toString(8), file_name.toString()]);
  return res.status;
}
platform.file_readlink = function(path_name) { return platform.io_action(fs.readlinkSync, path_name.toString()); }
platform.file_realpath = function(path_name, sep) {
  return platform.io_action(fs.realpathSync, path_name.toString())
                 .replaceAll(path.sep, sep.toString());
}
platform.file_rename = function(old_name, new_name) {
  platform.io_action(fs.renameSync, old_name.toString(), new_name.toString());
}
platform.file_stat = function(file_name) { return platform.io_action(fs.statSync, file_name.toString()); }
platform.file_symlink = function(path_name, new_path_name) {
  platform.io_action(fs.symlinkSync, path_name.toString(), new_path_name.toString());
}
platform.file_truncate = function(file_name, len) { platform.io_action(fs.truncateSync, file_name.toString(), len); }
platform.file_unlink = function(file_name) { platform.io_action(fs.unlinkSync, file_name.toString()); }
platform.file_utimes = function(file_name, atime, mtime) {
  platform.io_action(fs.utimesSync, file_name.toString(), atime, mtime);
}

// Dir
// As node cannot handle dirs with file descriptors, we need to emulate them.
// But this may lead to confusion, if dir fds are interchanged with file fds.
// Specifically with Dir.fchdir, but otherwise we would need to allocate a real fd,
// like above in Pipe.get_fd(), which is a bit overkill.
platform.directories = { __proto__: null, last: 0 }
platform.dir_chdir = function(dir_name) { platform.io_action(process.chdir, dir_name.toString()); }
platform.dir_chroot = function(_dir_name) {
  Opal.Kernel.$raise(Opal.NotImplementedError, 'Dir#chroot is not available on nodejs and compatible platforms');
}
platform.dir_close = function(fd) {
  let dir = platform.directories[fd];
  if (!dir) { return; }
  dir.handle.closeSync();
  delete platform.directories[fd];
}
platform.dir_home = function(sep) { return os.homedir().replaceAll(path.sep, sep.toString()); }
platform.dir_open = function(dir_name) {
  let handle = platform.io_action(fs.opendirSync, dir_name.toString()),
      fd = ++platform.directories.last;
  platform.directories[fd] = { handle: handle, eof: false, dot: false, dotdot: false };
  return fd;
}
platform.dir_mkdir = function(dir_name, mode) { platform.io_action(fs.mkdirSync, dir_name.toString(), { mode: mode }); }
platform.dir_next = function(fd) {
  let dir = platform.directories[fd];
  if (!dir) return;
  let entry = (!dir.eof) ? dir.handle.readSync() : null;
  if (entry) return entry.name;
  else dir.eof = true;
  if (!dir.dot) {
    dir.dot = true;
    return '.';
  }
  if (!dir.dotdot) {
    dir.dotdot = true;
    return '..';
  }
  return;
}
platform.dir_path = function(fd) { return platform.directories[fd].handle.path; }
platform.dir_rewind = function(fd) {
  let dir = platform.directories[fd];
  dir.handle = platform.io_action(fs.opendirSync, dir.handle.path);
  dir.eof = dir.dot = dir.dotdot = false;
}
platform.dir_unlink = function(dir_name) { platform.io_action(fs.rmdirSync, dir_name.toString()); }
platform.dir_wd = function(sep) { return process.cwd().replaceAll(path.sep, sep.toString()); }

});}
