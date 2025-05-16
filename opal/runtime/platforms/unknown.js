//
// For unknown platforms all functions for best platform support. Not so many though.
// This file is always loaded and sets functions and properties not implemented by drivers to defaults.
//
// This file also serves as template for supporting new platforms.
// To support a new platform:
// 1. add platform detction in platform_support.js
// 2. copy this file, name it after the platform
// 3. make sure its required in runtime.rb
// 4. start filling the copied file with platform support code
//    look at the node_compatible.js driver for args and return values.
//

// For new platforms uncomment and use proper name:
// if ("new platform name" === Opal.platform.name) {

Opal.queue(async function() {

const platform = Opal.platform;
const not_implemented = platform.not_implemented;

// imports
// For new platforms put imports here

// Helpers
// For new platforms put imports here

// RUBY_PLATFORM and some OS dependent switches
if (!platform.ruby_platform) {
  // All these must be set by the driver accordingly. For new platform driver remove the surrounding if.
  platform.ruby_platform = "opal";
  platform.windows = false;
  platform.fs_casefold = false;
  platform.null_device = "/dev/null";
  platform.sysconfdir = "/etc"
  platform.path_sep = ":";
}

// Some platform info
// For new platforms implement accodingly and remove the ||
platform.available_parallelism ||= ()=>1;
platform.machine ||= ()=>"unknown";
platform.nodename ||= ()=>"unknown";
platform.release ||= ()=>"unknown";
platform.sysname ||= ()=>"unknown";
platform.tmpdir ||= ()=>"/tmp";
platform.version ||= ()=>"unknown";

// TextDecoder
// For new platforms implement accodingly and remove the ||
platform.text_decoder ||= TextDecoder;

// Exit
// For new platforms implement accodingly and remove the ||
platform.exit ||= (status)=>console.log('Exited with status ' + status);


// Sleep
platform.sleep ||= platform.sleep_while;

// ARGV
// For new platforms implement accodingly and remove the ||
platform.argv ||= []

// ENV
if (!platform.env_keys) {
  // This is a simple emulation. For new platforms implement accodingly and remove the surrounding if.
  const env = { __proto__: null };
  platform.env_keys = ()=>Object.keys(env);
  platform.env_get = (key)=>env[key.toString()];
  platform.env_del = (key)=>{ delete env[key.toString()]; };
  platform.env_has = (key)=>env[key.toString()] != null;
  platform.env_set = (key, value)=>env[key.toString()]=value.toString();
}

// Process
// For new platforms implement accodingly and remove the ||
// platform.process_getegid = not_implemented;
// platform.process_setegid = not_implemented;
// platform.process_geteuid = not_implemented;
// platform.process_seteuid = not_implemented;
// platform.process_getgid = not_implemented;
// platform.process_setgid = not_implemented;
// platform.process_getgroups = not_implemented;
// platform.process_setgroups = not_implemented;
// platform.process_getuid = not_implemented;
// platform.process_setuid = not_implemented;
platform.process_sig_list ||= Opal.nil; // or use a Map, see node driver
// platform.process_kill = not_implemented;
// platform.process_pid = not_implemented;
// platform.process_ppid = not_implemented;
// platform.process_set_title = not_implemented;
// platform.process_is_primary = not_implemented;
// platform.process_is_worker = not_implemented;
// platform.process_fork = not_implemented;
// platform.process_worker_pid = not_implemented;
// platform.process_exec = not_implemented;
// platform.process_spawn = not_implemented;
// platform.process_wait = not_implemented;
// platform.process_waitall = not_implemented;

// IO.pipe
// For new platforms implement accodingly and remove the surrounding if.
// platform.io_pipe = not_implemented;
// platform.io_pipe_eof = not_implemented;

// IO.popen
// platform.io_popen = not_implemented;

// IO
// For new platforms implement accodingly and remove the ||

// The text_decoder may not be required for new platforms, but it is required by io_write below.
const text_decoder = (!platform.io_write) ? new TextDecoder('utf8') : null;

// io_close must be implemented
platform.io_close ||= (fd)=>{ if (fd > 2) not_implemented("IO for fd > 2"); }

// platform.io_fdatasync = not_implemented;
// platform.io_fstat = not_implemented;
// platform.io_fsync = not_implemented;
// platform.io_ioctl = not_implemented;

// io_open must be implemented, false means: not a TTY
platform.io_open ||= ()=>false;

// platform.io_open_path = not_implemented;
// platform.io_read = not_implemented;

// io_write must be implemented
platform.io_write ||= (fd, io_buffer, buffer_offset, _pos, count)=>{
  if (fd > 2) return not_implemented("IO for fd > 2");
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
// For new platforms implement accodingly and remove the ||
// platform.file_chmod = not_implemented;
// platform.file_chown = not_implemented;
// platform.file_fchmod = not_implemented;
// platform.file_fchown = not_implemented;
// platform.file_flock = not_implemented;
// platform.file_ftruncate = not_implemented;
// platform.file_get_umask = not_implemented;
// platform.file_set_umask = not_implemented;
// platform.file_lchmod = not_implemented;
// platform.file_lchown = not_implemented;
// platform.file_link = not_implemented;
// platform.file_lstat = not_implemented;
// platform.file_lutime = not_implemented;
// platform.file_mkfifo = not_implemented;
// platform.file_readlink = not_implemented;
// platform.file_realpath = not_implemented;
// platform.file_rename = not_implemented;
// platform.file_stat = not_implemented;
// platform.file_symlink = not_implemented;
// platform.file_truncate = not_implemented;
// platform.file_unlink = not_implemented;
// platform.file_utime = not_implemented;

// Dir
// For new platforms implement accodingly:
// platform.dir_chdir = not_implemented;
// platform.dir_chroot = not_implemented;
// platform.dir_close = not_implemented;
// platform.dir_home = not_implemented;
// platform.dir_open = not_implemented;
// platform.dir_mkdir = not_implemented;
// platform.dir_next = not_implemented;
// platform.dir_path = not_implemented;
// platform.dir_rewind = not_implemented;
// platform.dir_unlink = not_implemented;

// dir_wd must be implemented
platform.dir_wd ||= ()=>'/';

});

// For new platforms uncomment:
// }
