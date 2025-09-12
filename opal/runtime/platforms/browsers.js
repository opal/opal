//
// Browsers, Chrome, Firefox, Safari and others
//

if (Opal.platform.is_browser) {
Opal.queue(async function() {

// used vars
const platform = Opal.platform;

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
platform.sysname = ()=>platform.name;

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

// Sleep
if ((typeof(Opal.global.Atomics) === "object") && (typeof(Opal.global.SharedArrayBuffer) === "function")) {
  platform.sleep = platform.sleep_atomics;
}

// ARGV
platform.argv = [location.pathname];
(new URLSearchParams(location.search)).forEach((k, v)=>platform.argv.push(k + '=' + v));

// IO
let text_decoder = new TextDecoder('utf8');
platform.io_close = ()=>{};
platform.io_open = (_fd)=>false;
platform.io_write = (fd, io_buffer, buffer_offset, _pos, count)=>{
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
  if (fd > 2) return platform.not_implemented("IO for fd > 2");
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

// Dir

});}
