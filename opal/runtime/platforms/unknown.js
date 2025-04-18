//
// For unknown platforms all functions for best platform support
// This file also serves as template for supporting new platforms.
//

if ("unknown" === Opal.platform.name) {
Opal.queue(async function() {

const platform = Opal.platform;

// imports
// For new platforms put imports here

// Helpers
function not_available(fun) {
  platform.handle_unsupported_feature(fun + " is not available on this platform");
  return Opal.nil;
}

// RUBY_PLATFORM and some OS dependent switches
platform.ruby_platform = "opal";
platform.windows = false;
platform.fs_casefold = false;
platform.null_device = "/dev/null";
platform.sysconfdir = "/etc"
platform.path_sep = ":";

// Some platform info
platform.available_parallelism = ()=>1;
platform.machine = ()=>"unknown";
platform.nodename = ()=>"unknown";
platform.release = ()=>"unknown";
platform.sysname = ()=>"unknown";
platform.tmpdir = ()=>"/tmp";
platform.version = ()=>"unknown";

// Exit
platform.exit = (status)=>console.log('Exited with status ' + status);

// ARGV
platform.argv = []

// ENV
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
const text_decoder = new TextDecoder('utf8');
platform.io_close = (fd)=>{ if (fd > 2) not_available("IO for fd > 2"); }
platform.io_fdatasync = (_fd)=>not_available("IO#fdatasync");
platform.io_fstat = (_fd)=>not_available("IO#fstat");
platform.io_fsync = (_fd)=>not_available("IO#fsync");
platform.io_ioctl = (_cmd, _arg)=>not_available("IO#ioctl");
platform.io_open = (_fd)=>false;
platform.io_open_path = (_path_name, _flags, _perm)=>not_available("IO for fd > 2");
platform.io_read = (_fd, _io_buffer, _buffer_offset, _pos, _count)=>not_available("IO#read");
platform.io_write = (fd, io_buffer, buffer_offset, _pos, count)=>{
  if (fd > 2) return not_available("IO for fd > 2");
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
platform.file_ftruncate = (_fd, _len)=>not_available("File#truncate");
platform.file_get_umask = ()=>not_available("File.umask");
platform.file_set_umask = ()=>not_available("File.umask");
platform.file_lchmod = (_file_name, _mode)=>not_available("File.lchmod");
platform.file_link = (_path_name, _new_path_name)=>not_available("File.link");
platform.file_lstat = (_file_name)=>not_available("File.lstat");
platform.file_lutime = (_file_name, _atime, _mtime)=>not_available("File.lutime");
platform.file_mkfifo = (_file_name, _mode)=>not_available("File.mkfifo");
platform.file_readlink = (_path_name)=>not_available("File.readlink");
platform.file_realpath = (path_name, _sep)=>path_name.toString();
platform.file_rename = (_old_name, _new_name)=>not_available("File.rename");
platform.file_stat = (_file_name)=>Opal.Kernel.$raise(Opal.NotImplementedError, "File.stat is not available on this platform");// not_available("File.stat");
platform.file_symlink = (_path_name, _new_path_name)=>not_available("File.symlink");
platform.file_truncate = (_file_name, _len)=>not_available("File.truncate");
platform.file_unlink = (_file_name)=>not_available("File.unlink");
platform.file_utime = (_file_name, _atime, _mtime)=>not_available("File.utime");

// Dir
platform.dir_chdir = (_dir_name)=>not_available("Dir.chdir");
platform.dir_chroot = (_dir_name)=>not_available("Dir.chroot");
platform.dir_close = (_fd)=>not_available("Dir#close");
platform.dir_home = ()=>'.';
platform.dir_open = (_dir_name)=>not_available("Dir.new");
platform.dir_mkdir = (_dir_name, _mode)=>not_available("Dir.mkdir");
platform.dir_next = (_fd)=>not_available("Dir#next");
platform.dir_path = (_fd)=>not_available("Dir#path");
platform.dir_rewind = (_fd)=>not_available("Dir#rewind");
platform.dir_unlink = (_dir_name)=>not_available("Dir.unlink");
platform.dir_wd = ()=>'.';

});}
