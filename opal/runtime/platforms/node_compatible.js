// Driver for Node 22 or greater and GraalNodeJs
if (Opal.platform.name == "node") {
Opal.queue(async function() {

const platform = Opal.platform;

// imports
const child_process = require("node:child_process");
const cluster = require("node:cluster");
const fs = require("node:fs");
const os = require("node:os");
const path = require("node:path");
const process = Opal.global.process;
const url = require("node:url");

// we need to pass the 'node_modules' path to spawning processes, so lets detect it:
let node_modules_path;
if (fs.existsSync(path.join(process.cwd(), 'node_modules')))
  node_modules_path = path.resolve(path.join(process.cwd(), 'node_modules'));

// allow access to modules from stdlib, this is node specific and only used by open-uri
platform.modules = { child_process, fs, os, path, url };

// Helpers

// IO helper function to raise correct Ruby Error instead of platform specific error
function action(action, ...args) {
  try { return action(...args); }
  catch (error) {
    let code = error.code;
    // Errno is autoloaded, to make sure it gets loaded eventually, must use const_get here
    if (Opal.Object.$const_get('Errno').$constants().indexOf(code) >= 0) {
      let error_class = Opal.Errno.$const_get(code);
      Opal.Kernel.$raise(error_class.$new(error.message));
    }
    Opal.Kernel.$raise(error);
  }
};

// RUBY_PLATFORM and some OS dependent switches
if (os.platform().startsWith("win")) {
  platform.ruby_platform = "opal mswin";
  platform.windows = true;
  platform.fs_casefold = true;
  platform.null_device = "NUL";
  platform.sysconfdir = Opal.nil;
  platform.alt_sep = "\\";
  platform.path_sep = ";";
} else {
  if (os.platform().includes("linux")) platform.ruby_platform = "opal linux";
  else if (os.platform().includes("freebsd")) platform.ruby_platform = "opal freebsd";
  else if (os.platform().includes("darwin")) {
    platform.ruby_platform = "opal darwin";
    platform.macos = true;
  } else platform.ruby_platform = "opal";
  platform.fs_casefold = false
  platform.null_device = "/dev/null";
  platform.sysconfdir = "/etc"
  platform.path_sep = ":";
}
platform.sep = path.sep;

// Some platform info
platform.available_parallelism = os.availableParallelism;
platform.machine = os.machine;
platform.nodename = os.hostname;
platform.release = os.release;
platform.sysname = os.type;
platform.tmpdir = ()=>os.tmpdir().replaceAll(path.sep, '/');
platform.version = os.version;

// Exit
platform.exit = process.exit;

// Sleep
platform.sleep = platform.sleep_atomics;

// ARGV
platform.argv = process.argv.slice(1)
if (platform.argv[1] === '--') platform.argv.splice(1, 1);

// ENV
platform.env_keys = ()=>Object.keys(process.env).sort();
platform.env_get = (key)=>process.env[key];
platform.env_del = (key)=>{ delete process.env[key]; };
platform.env_has = (key)=>process.env[key] != null;
platform.env_set = (key, value)=> {
  if (key === "TZ") {
    // Node understands only timezones in the form of "TZ identifiers" like in the Table at
    // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones. To make setting TZ work
    // when given in Ruby style "PDT8:00:00", it must be converted to "Etc/GMT+8". TZ can be set to "PDT8:00:00",
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

// Syscalls
// Some of the functions are not available on all platforms node runs on.
platform.chdir = (dir_name)=>action(process.chdir, dir_name);
platform.chmod = (file_name, mode)=>action(fs.chmodSync, file_name, mode);
platform.chown = (file_name, uid, gid)=>action(fs.chownSync, file_name, uid, gid);
if (fs.fchmodSync) { platform.fchmod = (fd, mode)=>action(fs.fchmodSync, fd, mode); }
if (fs.fchownSync) { platform.fchown = (fd, uid, gid)=>action(fs.fchownSync, fd, uid, gid); }
platform.ftruncate = (fd, len)=>action(fs.ftruncateSync, fd, len);
platform.getegid = (typeof process.getegid === "function") ? process.getegid : ()=>-1;
platform.geteuid = (typeof process.geteuid === "function") ? process.geteuid : ()=>-1;
platform.getgid = (typeof process.getgid === "function") ? process.getgid : ()=>-1;
platform.getgroups = (typeof process.getgroups === "function") ? process.getgroups : ()=>[];
platform.getpid = ()=>process.pid;
platform.getppid = ()=>process.ppid;
platform.getuid = (typeof process.getuid === "function") ? process.getuid : ()=>-1;
platform.initgroups = (typeof process.initgroups === "function") ?
  (user, gid)=>action(process.initgroups, user, gid) : ()=>[];
platform.kill = (pid, signal)=>{
  if (children[pid]) {
    children[pid].kill(platform.process_sig_list.get('SIG' + signal));
    delete children[pid];
  } else {
    action(process.kill, pid, platform.process_sig_list.get('SIG' + signal));
  }
}
platform.link = (path_name, new_path_name)=>action(fs.linkSync, path_name, new_path_name);
platform.lstat = (file_name)=>action(fs.lstatSync, file_name);
platform.mkdir = (dir_name, mode)=>{
  action(fs.mkdirSync, dir_name, { mode: mode });
  // Sometimes on Windows mode is not set correctly in mkdirSync
  if (platform.windows) fs.chmodSync(dir_name, mode);
}
platform.readlink = (path_name)=>action(fs.readlinkSync, path_name).replaceAll(path.sep, '/');
platform.rename = (old_name, new_name)=>action(fs.renameSync, old_name, new_name);
platform.rmdir = (dir_name)=>{
  if (fs.existsSync(dir_name)) {
    // On Windows rmdirSync may throw the wrong exception, ENOENT instead of ENOTDIR
    let stat = fs.lstatSync(dir_name)
    if (!stat.isDirectory()) {
      let error_class = Opal.Object.$const_get('Errno').$const_get('ENOTDIR');
      Opal.Kernel.$raise(error_class.$new('not a directory'));
    }
  }
  action(fs.rmdirSync, dir_name);
}
platform.setegid = (typeof process.setegid === "function") ? (gid)=>action(process.setegid, gid) : ()=>-1;
platform.seteuid = (typeof process.seteuid === "function") ? (uid)=>action(process.seteuid, uid) : ()=>-1;
platform.setgid = (typeof process.setgid === "function") ? (gid)=>action(process.setgid, gid) : ()=>-1;
platform.setgroups = (grps)=>{
  if (typeof process.setgroups === "function") return action(process.setgroups, grps);
  return [];
}
platform.setproctitle = (title)=> { process.title = title; }
platform.setuid = (typeof process.setuid === "function") ? (uid)=>action(process.setuid, uid) : ()=>-1;
platform.stat = (file_name)=>action(fs.statSync, file_name);
platform.symlink = (path_name, new_path_name)=>action(fs.symlinkSync, path_name, new_path_name);
platform.truncate = (file_name, len)=>action(fs.truncateSync, file_name, len);
platform.unlink = (file_name)=>action(fs.unlinkSync, file_name);
platform.umask = process.umask

// Process
const children = { __proto__: null };
const traps = { __proto__: null };

platform.process_sig_list = (new Map()).set("EXIT",0).set("HUP",1).set("INT",2).set("ILL",4).set("TRAP",5).set("ABRT",6)
                                    .set("IOT",6).set("FPE",8).set("KILL",9).set("BUS",7).set("SEGV",11).set("SYS",31)
                                    .set("PIPE",13).set("ALRM",14).set("TERM",15).set("URG",23).set("STOP",19)
                                    .set("TSTP",20).set("CONT",18).set("CHLD",17).set("CLD",17).set("TTIN",21)
                                    .set("TTOU",22).set("IO",29).set("XCPU",24).set("XFSZ",25).set("VTALRM",26)
                                    .set("PROF",27).set("WINCH",28).set("USR1",10).set("USR2",12).set("PWR",30)
                                    .set("POLL",29);
platform.process_is_primary = ()=>cluster.isPrimary;
platform.process_is_worker = ()=>cluster.isWorker;
platform.process_fork = ()=>cluster.fork();
platform.process_worker_pid = (worker)=>worker.process.pid;
platform.process_spawn = function() {
  let res, opts = arguments[arguments.length - 1], wait = opts.wait;
  delete opts.wait;
  if (!opts.env) opts.env = process.env;
  if (node_modules_path) {
    if (!opts.env.NODE_PATH) opts.env.NODE_PATH = "";
    if (opts.env.NODE_PATH.length > 0) opts.env.NODE_PATH += platform.windows ? ';' : ':';
    opts.env.NODE_PATH += node_modules_path;
  }
  if (platform.windows) opts.windowsHide = true;
  else opts.shell = 'sh';
  if (wait) {
    res = child_process.spawnSync.apply(null, arguments);
    return { status: res.status, pid: res.pid, error: res.error,
      stdout: res.stdout ? res.stdout.toString() : null,
      stderr: res.stderr ? res.stderr.toString() : null };
  } else {
    res = child_process.spawn.apply(null, arguments);
    children[res.pid] = res;
    return { status: res.exitCode, pid: res.pid, error: null, stdout: '', stderr: '' }
  }
}
platform.process_trap = (signal, _command, block)=>{
  if (block == Opal.nil) block = null;
  signal = 'SIG' + signal;
  let last = traps[signal];
  if (last) process.off(signal, last);
  traps[signal] = block;
  if (block && block != Opal.nil) process.on(signal, traps[signal]);
  return last;
}

// IO.pipe
// In process pipe, because Nodejs does not support real pipes synchonously, so lets emulate them.
// For the Future: maybe can use unix sockets/named pipes for real IPC with cluster.fork() here.
platform.pipes = { __proto__: null };

class Pipe {
  static get_fd() {
    // Allocate a real FD, but don't actually use it for reading/writing.
    // It is still useful for stat or others though.
    let sep = path.sep, tmpdir = fs.mkdtempSync(os.tmpdir() + sep + "opal-pipe-emu-");
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
    let dv = io_buffer.data_view, i = 0, max_read = Math.min(this.write_pos, dv.byteLength - buffer_offset, count);
    for (; i < max_read; i++) { dv.setUint8(buffer_offset++, this.data_view.getUint8(i)); }
    let buffer = this.data_view.buffer.slice(max_read);
    this.data_view = new DataView(buffer);
    this.write_pos -= max_read;
    return max_read;
  }
  write(io_buffer, buffer_offset, count) {
    if (count == null) count = Infinity;
    let dv = io_buffer.data_view, i = 0, max_write = Math.min(count, dv.byteLength - buffer_offset);
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
      try { fs.closeSync(fd) } catch {}
      fs.rmdirSync(this.rtd, { recursive: true });
    } else if (!this.wclosed) {
      this.wclosed = true;
      try { fs.closeSync(fd) } catch {}
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

platform.io_pipe = ()=>{
  let pp = new Pipe();
  platform.pipes[pp.read_fd] = pp;
  platform.pipes[pp.write_fd] = pp;
  return [pp.read_fd, pp.write_fd];
}
platform.io_pipe_eof = (fd)=>{
  if (platform.pipes[fd]) return platform.pipes[fd].eof(fd);
  return false;
}

// IO.popen
class SpawnPipe {
  constructor(buff_size, cmd, args, mode, options)  {
    this.write_pos = 0;
    this.closed = false;
    [this.pfd, this.ptd] = Pipe.get_fd();
    if (options.err) {
      this.err = options.err;
      delete options.err;
    }
    if (mode == 'r') {
      // simply spawnSync and read data afterwards
      this.chpr = child_process.spawnSync(cmd, args, options);
      if (this.chpr.stdout) {
        let length = this.chpr.stdout.byteLength;
        if (this.err == 'out') length += this.chpr.stderr.byteLength
        let a = new ArrayBuffer(length),
            u = new Uint8Array(a);
        this.chpr.stdout.copy(u);
        if (this.err == 'out') this.chpr.stderr.copy(u, this.chpr.stdout.byteLength);
        this.data_view = new DataView(a);
        this.write_pos = a.byteLength;
      } else {
        this.data_view = new DataView(new ArrayBuffer(buff_size))
      }
    } else {
      this.data_view = new DataView(new ArrayBuffer(buff_size));
      this.tencoder = new TextEncoder();
      let pipe = this;
      function process_data(data) {
        if (!data) return;
        let i = 0, uint8ary = pipe.tencoder.encode(data.toString('utf8'));
        if ((pipe.data_view.byte_length - pipe.write_pos) < uint8ary.byteLength) {
          let buffer = pipe.data_view.buffer.transfer(pipe.write_pos + uint8ary.byteLength)
          pipe.data_view = new DataView(buffer);
        }
        for (; i < uint8ary.byteLength;) { pipe.data_view.setUint8(pipe.write_pos++, uint8ary[i++]); }
      }
      this.chpr = child_process.spawn(cmd, args, options);
      if (this.chpr.stdout) {
        this.chpr.stdout.on('data', process_data);
        this.chpr.stdout.on('end', process_data);
        if (this.err == 'out') {
          this.chpr.stderr.on('data', process_data);
          this.chpr.stderr.on('end', process_data);
        }
      }
      this.chpr.on('exit', function(_code) { pipe.closed = true; });
    }
  }
  get fd() { return this.pfd; }
  get pid() { return this.chpr.pid; }
  read(io_buffer, buffer_offset, count) {
    if (this.write_pos === 0) return 0; // nothing to read
    if (count == null) count = Infinity;
    let dv = io_buffer.data_view, i = 0,
        max_read = Math.min(this.write_pos, dv.byteLength - buffer_offset, count);
    for (; i < max_read; i++) { dv.setUint8(buffer_offset++, this.data_view.getUint8(i)); }
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
  eof(_fd) { return this.write_pos < 1; }
  close(_fd) {
    if (!this.closed) {
      this.closed = true;
      try { if (this.chpr) this.chpr.kill(); } catch {}
      try { fs.closeSync(this.pfd) } catch {}
      fs.rmdirSync(this.ptd, { recursive: true });
    }
    return this.chpr.status == null ? this.chpr.exitCode : this.chpr.status;
  }
}

platform.io_popen = function(cmd, args, mode, options) {
  let pp = new SpawnPipe(1024, cmd, args, mode, options);
  platform.pipes[pp.fd] = pp;
  return [pp.fd, pp.pid];
}

// IO
function emulate_ctx(c, t, x , path_name, perm) {
  if (c && x && fs.existsSync(path_name))
    Opal.Kernel.$raise(Opal.Errno.EEXIST, "file already exists, open '" + path_name + "'");
  if (c && !fs.existsSync(path_name)) fs.writeFileSync(path_name, '', { mode: perm });
  if (!c || x) platform.stat(path_name); // will raise if file doesn't exist
  if (t) platform.truncate(path_name, 0);
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

platform.io_close = (fd)=>{
  if (fd < 3) return; // closing fd < 3 will confuse node, so we don't do it
  if (platform.pipes[fd]) {
    let status = platform.pipes[fd].close(fd);
    delete platform.pipes[fd];
    return status;
  } else {
    // Guard against double close from shared fd.
    // This can happen e.g. via ::IO#reopen.
    try { fs.closeSync(fd); } catch {}
  }
}
platform.io_fdatasync = (fd)=>{ if (fd > 2) action(fs.fdatasyncSync, fd); }
platform.io_fstat = (fd)=>action(fs.fstatSync, fd);
platform.io_fsync = (fd)=>{ if (fd > 2) action(fs.fsyncSync, fd); }
platform.io_open = (fd)=>{
  let tty = false, pipe = false, file = false, channel;
  if (fd == 0) channel = process.stdin;
  else if (fd == 1) channel = process.stdout;
  else if (fd == 2) channel = process.stderr;
  tty = channel ? channel.isTTY : false;
  if (fd < 3) pipe = !tty;
  if (platform.pipes[fd]) {
    file = false;
    pipe = true;
  } else { try { file = fs.fstatSync(fd).isFile(); } catch {} }
  return [tty, pipe, file];
};
platform.io_open_path = (path_name, flags, perm)=>{
  let mode = flags_to_mode(flags);
  if (!mode) mode = emulated_flags_to_mode(flags, path_name, perm);
  return action(fs.openSync, path_name, mode, perm);
}
platform.io_read = (fd, io_buffer, buffer_offset, pos, count, is_file)=>{
  let pp = platform.pipes[fd];
  if (pp) return pp.read(io_buffer, buffer_offset, count);
  if (is_file) return action(fs.readSync, fd, io_buffer.data_view, buffer_offset, count, pos);
  while (true) {
    try { return action(fs.readSync, fd, io_buffer.data_view, buffer_offset, count); }
    catch (e) {
      if (e instanceof Opal.Errno.EAGAIN) {
        let oe = Opal.exceptions;
        if (oe[oe.length - 1] === e) Opal.exceptions.pop();
        platform.sleep(0.010); // 10ms
      }
      else throw(e);
    }
  }
};
platform.io_tty_goto = (fd, col, lin)=>{}
platform.io_write = (fd, io_buffer, buffer_offset, pos, count)=>{
  let data = io_buffer.data_view;
  // Also in theory its possible to use fs.writeSync for std*, but in reality that works only half the time and
  // causes problems.
  if (0 < fd && fd < 3) {
    if (buffer_offset > 0 || data.byteLength > count) data = new DataView(data.buffer, buffer_offset, count);
    if (fd === 1) process.stdout.write(data, 'utf8', ()=>{});
    else if (fd === 2) process.stderr.write(data, 'utf8', ()=>{});
    return data.byteLength;
  }
  let pp = platform.pipes[fd];
  if(pp) return pp.write(io_buffer, buffer_offset, count);
  return action(fs.writeSync, fd, data, buffer_offset, count, pos);
};

// File
platform.file_lutime = (file_name, atime, mtime)=>action(fs.lutimesSync, file_name, atime, mtime);
if (!platform.windows) {
  platform.file_mkfifo = (file_name, mode)=>{
    let mode_s = mode.toString(8);
    if (mode_s.length > 3) mode_s = mode_s.slice(mode_s.length - 3);
    let res = child_process.spawnSync('mkfifo', ['-m', mode_s, file_name]);
    return res.status;
  }
}
platform.file_realpath = (path_name, sep)=>{
  return action(fs.realpathSync, path_name).replaceAll(path.sep, sep);
}
platform.file_utime = (file_name, atime, mtime)=>action(fs.utimesSync, file_name, atime, mtime);

// Dir
// As node cannot handle dirs with file descriptors, we need to emulate them.
// But this may lead to confusion, if dir fds are interchanged with file fds.
// Specifically with Dir.fchdir, but otherwise we would need to allocate a real fd,
// like above in Pipe.get_fd(), which is a bit overkill.
let directories = { __proto__: null, last: 0 }
platform.dir_close = (fd)=>{
  let dir = directories[fd];
  if (!dir) { return; }
  dir.handle.closeSync();
  delete directories[fd];
}
platform.dir_home = ()=>os.homedir();
platform.dir_open = (dir_name)=>{
  let handle = action(fs.opendirSync, dir_name), fd = ++directories.last;
  directories[fd] = { __proto__: null, handle: handle, eof: false, dot: false, dotdot: false };
  return fd;
}
platform.dir_next = (fd)=>{
  let dir = directories[fd];
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
}
platform.dir_path = (fd)=>directories[fd].handle.path;
platform.dir_rewind = (fd)=>{
  let dir = directories[fd];
  dir.handle = action(fs.opendirSync, dir.handle.path);
  dir.eof = dir.dot = dir.dotdot = false;
}
platform.dir_wd = ()=>process.cwd();

// And finally, load and compile ruby files
// This is called from Opal.load or Opal.require and facilitates direct loading of files, just like the former
// stdlib/nodejs/require did. It could or should however respect LOAD_PATH, but thats for the future.
platform.load_file = function(normalized_path) {
  if (!Opal.Opal.Compiler) {
    throw new Error("file '" + normalized_path + "' cannot be loaded, please require 'opal-parser' first");
  }
  if (!fs.existsSync(normalized_path)) normalized_path += '.rb';
  let ruby = action(fs.readFileSync, normalized_path).toString(),
      compiler = Opal.Opal.Compiler.$new(ruby, (new Map().set("requirable", true).set("file", normalized_path))),
      js = compiler.$compile(), requires = compiler.$requires(), path;
  for (path of requires) { platform.load_file(path, Opal.normalize(path)); }
  eval(js);
}

});}
