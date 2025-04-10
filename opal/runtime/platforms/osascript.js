//
// Apple OSAScript engine
//
if ("osascript" === Opal.platform.name) {
Opal.queue(async function() {

debugger

const platform = Opal.platform;
const notimpl = Opal.handle_unsupported_feature;

// imports
ObjC.import("stdlib")
ObjC.import("stdio");
ObjC.import("unistd");
ObjC.import("objc");
ObjC.import("Foundation");

if (typeof(Opal.global.TextEncoder) === "undefined") {
  Opal.global.TextEncoder = class {
    #internal_encode(js_string, uint8_array) {
      let oc_str = $.NSString.stringWithString(js_string.valueOf());
      let oc_data = oc_str.dataUsingEncoding($.NSUTF8StringEncoding);
      let length = Number(oc_data.length);
      let bytes = oc_data.bytes;
      if (!uint8_array) uint8_array = new Uint8Array(length);
      for (let i = 0; i < length; i++) {
        uint8_array[i] = bytes[i];
      }
      return { uint8_array: uint8_array, length: length };
    }
    encode(js_string) {
      return this.#internal_encode(js_string).uint8_array;
    }
    encodeInto(js_string, uint8_array) {
      return { read: js_string.length,
        written: this.#internal_encode(js_string, uint8_array).length };
    }
    get encoding() { return "utf-8"; }
  }
}

if (typeof(Opal.global.TextDecoder) === "undefined") {
  Opal.global.TextDecoder = class {
    constructor(label, options) {
      if (!label || ["utf8", "utf-8", "unicode-1-1-utf-8"].includes(label)) {
        this.oc_encoding = $.NSUTF8StringEncoding;
      } else if (["utf-16", "utf-16le"].includes(label)) {
        this.oc_encoding = $.NSUTF16LittleEndianStringEncoding;
      } else if ("utf16-be" === label) {
        this.oc_encoding = $.NSUTF16BigEndianStringEncoding;
      } else if (["ascii", "latin1", "us-ascii", "iso-8859-1", "iso8859-1", "iso88591", "iso_8859-1", "ansi_x3.4-1968", "cp1252",
        "cp819", "csisolatin1", "ibm819", "iso-ir-100", "iso_8859-1:1987", "l1", "windows-1252", "x-cp1252"].includes(label)) {
        this.oc_encoding = $.NSISOLatin1StringEncoding;
      } else if (["csisolatin2", "iso-8859-2", "iso-ir-101", "iso8859-2", "iso88592", "iso_8859-2", "iso_8859-2:1987", "l2",
        "latin2"].includes(label)) {
        this.oc_encoding = $.NSISOLatin2StringEncoding;
      } else if (["csmacintosh", "mac", "macintosh", "x-mac-roman"].includes(label)) {
        this.oc_encoding = $.NSMacOSRomanStringEncoding;
      } else if (["csiso2022jp", "iso-2022-jp"].includes(label)) {
        this.oc_encoding = $.NSISO2022JPStringEncoding;
      } else if (["cseucpkdfmtjapanese", "euc-jp", "x-euc-jp"].includes(label)) {
        this.oc_encoding = $.NSJapaneseEUCStringEncoding;
      } else if (["csshiftjis", "ms_kanji", "shift-jis", "shift_jis", "sjis", "windows-31j", "x-sjis" ].includes(label)) {
        this.oc_encoding = $.NSShiftJISStringEncoding;
      } else if (["cp1250", "windows-1250", "x-cp1250"].includes(label)) {
        this.oc_encoding = $.NSWindowsCP1250StringEncoding;
      } else if (["cp1251", "windows-1251", "x-cp1251"].includes(label)) {
        this.oc_encoding = $.NSWindowsCP1251StringEncoding;
      } else if (["cp1253", "windows-1253", "x-cp1253"].includes(label)) {
        this.oc_encoding = $.NSWindowsCP1253StringEncoding;
      } else if (["cp1254", "csisolatin5", "iso-8859-9", "iso-ir-148", "iso8859-9", "iso88599", "iso_8859-9", "iso_8859-9:1989",
        "l5", "latin5", "windows-1254", "x-cp1254"].includes(label)) {
        this.oc_encoding = $.NSWindowsCP1254StringEncoding;
      } else { throw new Error("unsupported encoding " + label); }
      this.enc = label;
      this.fat = (options && options.fatal === true) ? true : false;
    }
    decode(buffer, _stream) {
      let length = buffer.byteLength;
      if (length === 0) { return ""; }
      let oc_data = $.NSMutableData.dataWithLength(length);
      let data_view;
      if (typeof(buffer.buffer) === "object") {
        data_view = new DataView(buffer.buffer, buffer.byteOffset, buffer.byteLength);
      } else {
        data_view = new DataView(buffer);
      }
      for (let i = 0; i < length; i++) {
        oc_data.mutableBytes[i] = data_view.getUint8(i);
      }
      let oc_string = $.NSString.alloc.initWithDataEncoding(oc_data, this.oc_encoding);
      if (oc_string.isNil()) {
         if (this.fat) throw new TypeError('buffer does not match encoding');
         return "";
      }
      return oc_string.js;
    }
    get encoding() { return this.enc; }
    get fatal() { return this.fat; }
  }
}

platform.text_encoder = new TextEncoder();
platform.utf8_text_decoder = new TextDecoder('utf8');

platform.exit = $.exit;

platform.error_with_code = function(code) {
  let err = new Error();
  err.code = code;
  return err;
}

// ARGV
platform.argv = $.NSProcessInfo.processInfo.arguments.js.slice(4); // osascript -l JavaScript script.js ...

// ENV
platform.env_keys = ()=> { Object.keys($.NSProcessInfo.processInfo.environment.js); };
platform.env_get = (k)=> {
  try {
    if (typeof(k) === "string") {
      let r = $.NSProcessInfo.processInfo.environment.valueForKey(k).js;
      if (typeof(r) === "string") return r;
    }
    return Opal.nil
  } catch {
    return Opal.nil
  }
};
platform.env_del = (k)=> { $.unsetenv(k); };
platform.env_has = (k)=> { platform.env_get() == Opal.nil ? false : true };
platform.env_set = (k, v)=> { $.setenv(k, v, 1); };

// IO
// helper functions
function is_objc_nil(o) {
  return (o == null || (typeof(o.isNil) === "function" && o.isNil())) ? true : false;
};
function is_empty_obj(o) {
  return (is_objc_nil(o) || Number(o.length) === 0) ? true : false;
};
function fh_write(fh, s) {
  let err = $(), str = $.NSString.stringWithString(s);
  // try UTF8 first
  let data = str.dataUsingEncoding($.NSUTF8StringEncoding);
  if (is_empty_obj(data)) {
    // might be binary data, try ISOLatin1 which preserves all 8bits of a byte
    data = str.dataUsingEncoding($.NSISOLatin1StringEncoding);
  }
  fh.writeDataError(data, err);
};
function ns_data_to_string(data, count) {
  // try UTF8 first
  let res;
  if (count > 1) {
    // with count == 1 decoding UTF8 wont work, due to multibyte characters in UTF8
    // so we only try UTF8 if count is larger
    res = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
  }
  if (is_empty_obj(res)) {
    // might be binary data, try ISOLatin1 which preserves all 8bits of a byte
    res = $.NSString.alloc.initWithDataEncoding(data, $.NSISOLatin1StringEncoding);
  }
  if (!is_objc_nil(res)) { return res.js; }
};


platform.io_close = function(fd) {
  let err = $(), fh = platform.file_handles.get(fd);
  fh.closeAndReturnError(err);
  platform.file_handles.delete(fd);
};
platform.io_open = function(fd) {
  let fh = platform.file_handles.get(fd);
  if (fh) return;
  if (fd === 0) { fh = $.NSFileHandle.fileHandleWithStandardInput; }
  else if (fd === 1) { fh = $.NSFileHandle.fileHandleWithStandardOutput; }
  else if (fd === 2) { fh = $.NSFileHandle.fileHandleWithStandardError; }
  else { fh = $.NSFileHandle.alloc.initWithFileDescriptor(fd); }
  platform.file_handles.set(fd, fh);
};
platform.io_read = function(fd, io_buffer, buffer_offset, pos, count) {
  if (count === 0) { return ""; }
  let data, err = $(), fh = platform.file_handles.get(fd);
  if (count > 0) { data = fh.readDataUpToLengthError(count, err); }
  else { data = fh.readDataToEndOfFileAndReturnError(err); }
  if (is_empty_obj(data)) { throw Opal.EOFError.$new(); }
  if (count === 1) { return data.bytes[0]; }
  let res = ns_data_to_string(data, count);
  return (typeof(res) === "string") ? res : "";
};
platform.io_seek = function(offs, fd) {
  let err = $(), fh = platform.file_handles.get(fd);
  fh.seekToOffsetError(offs, err);
};
platform.io_write = function(fd, io_buffer, buffer_offset, pos, count) {
  let fh = platform.file_handles.get(fd);
  fh_write(fh, s);
};

// File System
platform.fm = $.NSFileManager.defaultManager;
platform.file_handles = new Map();

platform.fs = {
  constants: { F_OK: 0, R_OK: 4, W_OK: 2, X_OK: 1 },
  accessSync: function (path, mode) {
    let sp = $.NSString.stringWithString(path).stringByStandardizingPath
    let res = true, fm = platform.fm, fs = platform.fs;
    if (mode & fs.constants.F_OK) {
      res = fm.fileExistsAtPath(sp);
      if (!re) { throw platform.error_with_code('ENOENT'); }
    }
    if (res && (mode & fs.constants.R_OK)) { res = fm.isReadableFileAtPath(sp); }
    if (res && (mode & fs.constants.W_OK)) { res = fm.isWritableFileAtPath(sp); }
    if (res && (mode & fs.constants.X_OK)) { res = fm.isExecutableFileAtPath(sp); }
    if (res) return true;
    throw platform.error_with_code('EACCES');
  },
  closeSync: platform.io_close,
  fsyncSync: function (fd) {
    let err = $();
    let fh = platform.file_handles.get(fd);
    fh.synchronizeAndReturnError(err);
  },
  lstatSync: notimpl,     // https://nodejs.org/docs/latest/api/fs.html#fslstatsyncpath-options
  openSync: function(path, flags, _mode) {
    let fh, fd, sp = $.NSString.stringWithString(path).stringByStandardizingPath;
    if (flags && ('r' === flags || 'rs' === flags)) {
      fh = $.NSFileHandle.fileHandleForReadingAtPath(sp);
    } else {
      if (!platform.fm.fileExistsAtPath(sp)) platform.fm.createFileAtPathContentsAttributes(sp, $.NSData.alloc.init, $());
      fh = $.NSFileHandle.fileHandleForUpdatingAtPath(sp);
    }
    fd = fh.fileDescriptor;
    platform.file_handles.set(fd, fh);
    return fd;
  },
  readdirSync: notimpl,   // https://nodejs.org/docs/latest/api/fs.html#fsreaddirsyncpath-options
  readFileSync: function(path_or_fd, _options) {
    let data;
    if (typeof(path_or_fd) === "string") {
      let sp = $.NSString.stringWithString(path_or_fd).stringByStandardizingPath;
      data = $.NSData.dataWithContentsOfFile(sp);
    } else if (typeof(path_or_fd) === "number") {
      let err = $(), fh = platform.file_handles.get(path_or_fd);
      data = fh.readDataToEndOfFileAndReturnError(err);
    }
    if (is_empty_obj(data)) { return ""; }
    let res = ns_data_to_string(data);
    if (typeof(res) === "string") return res;
    throw platform.error_with_code('ENOENT');
  },  // https://nodejs.org/docs/latest/api/fs.html#fsreadfilesyncpath-options
  realpathSync: notimpl,  // https://nodejs.org/docs/latest/api/fs.html#fsrealpathsyncpath-options
  statSync: notimpl,      // https://nodejs.org/docs/latest/api/fs.html#fsstatsyncpath-options
  symlinkSync: notimpl,   // https://nodejs.org/docs/latest/api/fs.html#fssymlinksynctarget-path-type
  unlinkSync: function(path) {
    let err = $();
    platform.fm.removeItemAtPathError($.NSString.stringWithString(path).stringByStandardizingPath, err);
  },
  writeFileSync: function(path_or_fd, s, _options) {
    let fh;
    if (typeof(path_or_fd) === "string") {
      let sp = $.NSString.stringWithString(path).stringByStandardizingPath;
      fh = $.NSFileHandle.fileHandleForWritingAtPath(sp);
    } else if (typeof(path_or_fd) === "number") {
      fh = platform.file_handles.get(path_or_fd);
    }
    fh_write(fh, s);
  }
};

// OS
platform.os = { homedir: function() { return $.NSHomeDirectory().js; }}

// Path
function check_path(p) {
  return $.NSString.alloc.initWithString(p).stringByStandardizingPath.js;
  // Should use $.realpath but its crashing osascript all the time
}
platform.path = {
  sep: '/',
  isAbsolute: (s)=>{ return (s[0] === platform.path.sep ? true : false); },
  normalize: (p)=>{ return p; }, // already normalized by resolve
  resolve: function (p1, p2) {
    let res = check_path(p2);
    if (platform.path.isAbsolute(res)) { return res; }
    res = check_path(p1 + platform.path.sep + p2)
    if (platform.path.isAbsolute(res)) { return res; }
    return platform.process.cwd();
  }
};

// Process
platform.process = {
  cwd: function() { return platform.fm.currentDirectoryPath.js; },
  chdir: function(d) { platform.fm.changeCurrentDirectoryPath(d); },
  pid: $.NSProcessInfo.processInfo.processIdentifier
};

// Child Process
platform.child_process = {
  execSync: notimpl,  // https://nodejs.org/docs/latest/api/child_process.html#child_processexecsynccommand-options
  spawnSync: notimpl  // https://nodejs.org/docs/latest/api/child_process.html#child_processspawnsynccommand-args-options
};

// Cluster
platform.cluster = { fork: notimpl };

});}
