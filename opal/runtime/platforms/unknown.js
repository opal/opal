//
// For unknown platforms all functions for best platform support.
// This file is always loaded and set functions not implemented by driver to defaults.
//
// This file also serves as template for supporting new platforms.
// To support a new platform:
// 1. add platform detction in platform_support.js
// 2. copy this file, name it after the platform
// 3. make sure its required in runtime.rb
// 4. start filling the copied file with platform support code
// Look at the node_compatible.js driver for args and return values.
//

// For new platforms uncomment and user proper name
// if ("new platform name" === Opal.platform.name) {

Opal.queue(async function() {

const platform = Opal.platform;
const not_available = platform.not_available;

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
platform.process_getegid ||= ()=>-1;
platform.process_setegid ||= ()=>-1;
platform.process_geteuid ||= ()=>-1;
platform.process_seteuid ||= ()=>-1;
platform.process_getgid ||= ()=>-1;
platform.process_setgid ||= ()=>-1;
platform.process_getgroups ||= ()=>[];
platform.process_setgroups ||= ()=>[];
platform.process_getuid ||= ()=>-1;
platform.process_setuid ||= ()=>-1;
platform.process_sig_list ||= new Map();
platform.process_kill ||= ()=>not_available("Process.kill");
platform.process_pid ||= ()=>not_available("Process.pid");
platform.process_ppid ||= ()=>not_available("Process.ppid");
platform.process_set_title ||= ()=>not_available("Process.setproctitle");
platform.process_is_primary ||= ()=>not_available("Process.fork");
platform.process_is_worker ||= ()=>not_available("Process.fork");
platform.process_fork ||= ()=>not_available("Process.fork");
platform.process_worker_pid ||= ()=>not_available("Process.fork");
platform.process_exec ||= ()=>not_available("#`");
platform.process_spawn ||= ()=>not_available("Process.spawn");
platform.process_wait ||= ()=>not_available("Process.wait");
platform.process_waitall ||= ()=>not_available("Process.waitall");

// IO.pipe
if (!platform.io_pipe) {
  // For new platforms implement accodingly and remove the surrounding if.
  platform.io_pipe = ()=>not_available("IO.pipe");
  platform.io_pipe_eof = ()=>not_available("IO#eof for pipes");
}

// IO.popen
platform.io_popen ||= ()=>not_available("IO.popen");

// IO
// For new platforms implement accodingly and remove the ||
// The TextDecoder may not be required for new platforms.
const text_decoder = (!platform.io_write) ? new TextDecoder('utf8') : null;
platform.io_close ||= (fd)=>{ if (fd > 2) not_available("IO for fd > 2"); }
platform.io_fdatasync ||= ()=>not_available("IO#fdatasync");
platform.io_fstat ||= ()=>not_available("IO#fstat");
platform.io_fsync ||= ()=>not_available("IO#fsync");
platform.io_ioctl ||= ()=>not_available("IO#ioctl");
platform.io_open ||= ()=>false;
platform.io_open_path ||= ()=>not_available("IO for files");
platform.io_read ||= ()=>not_available("IO#read");
platform.io_write ||= (fd, io_buffer, buffer_offset, _pos, count)=>{
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
// For new platforms implement accodingly and remove the ||
platform.file_chmod ||= ()=>not_available("File.chmod");
platform.file_chown ||= ()=>not_available("File.chown");
platform.file_fchmod ||= ()=>not_available("File#chmod");
platform.file_fchown ||= ()=>not_available("File#chown");
platform.file_flock ||= ()=>not_available("File#flock");
platform.file_ftruncate ||= ()=>not_available("File#truncate");
platform.file_get_umask ||= ()=>not_available("File.umask");
platform.file_set_umask ||= ()=>not_available("File.umask");
platform.file_lchmod ||= ()=>not_available("File.lchmod");
platform.file_link ||= ()=>not_available("File.link");
platform.file_lstat ||= ()=>not_available("File.lstat");
platform.file_lutime ||= ()=>not_available("File.lutime");
platform.file_mkfifo ||= ()=>not_available("File.mkfifo");
platform.file_readlink ||= ()=>not_available("File.readlink");
platform.file_realpath ||= ()=>not_available("File.realpath");
platform.file_rename ||= ()=>not_available("File.rename");
platform.file_stat ||= ()=>not_available("File.stat");
platform.file_symlink ||= ()=>not_available("File.symlink");
platform.file_truncate ||= ()=>not_available("File.truncate");
platform.file_unlink ||= ()=>not_available("File.unlink");
platform.file_utime ||= ()=>not_available("File.utime");

// Dir
// For new platforms implement accodingly and remove the ||
platform.dir_chdir ||= ()=>not_available("Dir.chdir");
platform.dir_chroot ||= ()=>not_available("Dir.chroot");
platform.dir_close ||= ()=>not_available("Dir#close");
platform.dir_home ||= ()=>'/';
platform.dir_open ||= ()=>not_available("Dir.new");
platform.dir_mkdir ||= ()=>not_available("Dir.mkdir");
platform.dir_next ||= ()=>not_available("Dir#next");
platform.dir_path ||= ()=>not_available("Dir#path");
platform.dir_rewind ||= ()=>not_available("Dir#rewind");
platform.dir_unlink ||= ()=>not_available("Dir.unlink");
platform.dir_wd ||= ()=>'/';

});

// For new platform uncomment
// }
