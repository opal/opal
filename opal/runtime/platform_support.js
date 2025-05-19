(function(Opal) {
  "use strict";
  // Platform support
  // ----------------

  // Sets the Opal.platform object with the following keys:
  //   is_browser: set to true if the platform is a browser
  //   name:       string, name of the platform if detected or "unknown"
  //   tty:        set to true if platform supports tty, default false
  // Then additional keys for APIs are added to Opal.platform object in platform.js.
  var $platform = { is_browser: false, name: "unknown" };
  Opal.platform = $platform;

  // These are always the same across all platforms
  $platform.clock_realtime = function() { return Date.now(); };
  $platform.clock_monotonic = (typeof(Opal.global.performance) === "object") ? ()=>performance.now() : null;

  //
  // Identify platform
  //

  // All browsers and browser based app platforms
  if (typeof(document) === "object" && typeof navigator === "object" && typeof navigator.userAgent === "string") {
    var nav_ua = navigator.userAgent;
    if (nav_ua.indexOf("Firefox") >= 0) { $platform.name = "firefox"; }
    else if (nav_ua.indexOf("Chrome") >= 0) { $platform.name = "chrome" }
    else if (nav_ua.indexOf("Safari") >= 0) { $platform.name = "safari" }
    Opal.platform.is_browser = true;
  }

  // All the node compatible server and desktop platforms
  /* global Bun, Deno, Graal */
  else if (typeof(Bun) === "object" && Bun.version) { $platform.name = "bun"; }
  else if (typeof(Deno) === "object" && Deno.version?.deno) { $platform.name = "deno"; }
  else if (typeof(process) === "object" && process.versions?.node) {
    $platform.name = (typeof(Graal) === "object" && Graal.versionGraalVM) ? "graalnodejs" : "node";
  }

  // Mini-Racer
  // else if (typeof(opalminiracer) !== "undefined") { $platform.name = "mini_racer"; }

  //
  // Handle unsupported features
  //
  $platform.not_implemented = ()=>Opal.Kernel.$raise(Opal.NotImplementedError);

  //
  // TextDecoder
  //

  // Shim if TextDecoder is missing; QuickJS, mini_racer, etc.
  const text_decoder_labels_ascii = ["ansi_x3.4-1968", "ascii", "cp1252", "cp819", "csisolatin1", "ibm819",
                                     "iso-8859-1", "iso-ir-100", "iso8859-1", "iso88591", "iso_8859-1",
                                     "iso_8859-1:1987", "l1", "latin1", "us-ascii", "windows-1252", "x-cp1252"];
  const text_decoder_labels_utf8 = ["unicode-1-1-utf-8", "utf-8", "utf8"];
  Opal.generic_text_decoder = class {
    constructor(label, options) {
      if (text_decoder_labels_utf8.includes(label)) this.utf8 = true;
      else if (text_decoder_labels_ascii.includes(label)) this.ascii = true;
      if (options) this.fatal = options.fatal;
    }
    decode(buffer) {
      let result = '';
      if (buffer instanceof ArrayBuffer) {
        if (this.ascii || this.utf8) buffer = new Uint8Array(buffer);
        else buffer = new Uint16Array(buffer);
      } else if (buffer instanceof DataView) {
        if (this.ascii || this.utf8) buffer = new Uint8Array(buffer.buffer, buffer.byteOffset, buffer.byteLength);
        else buffer = new Uint16Array(buffer.buffer, buffer.byteOffset, Math.floor(buffer.byteLength/2));
      }
      if (this.utf8) {
        let bytes_needed = 0, code_point = 0;
        buffer.forEach((v)=>{
          if (bytes_needed > 0) {
            if (0x80 <= v && v <= 0xBF) {
              code_point = (code_point << 6) | (v & 0x3F);
              bytes_needed--;
            } else {
              if (this.fatal) throw new TypeError('invalid encoding');
              bytes_needed = 0;
              result += '�';
            }
          } else {
            if (v <= 0x7F) {
              bytes_needed = 0;
              code_point = v & 0xFF;
            } else if (v <= 0xDF) {
              bytes_needed = 1;
              code_point = v & 0x1F;
            } else if (v <= 0xEF) {
              bytes_needed = 2;
              code_point = v & 0x0F;
            } else if (v <= 0xF4) {
              bytes_needed = 3;
              code_point = v & 0x07;
            } else {
              if (this.fatal) throw new TypeError('invalid encoding');
              code_point = 0xFFFD;
            }
          }
          if (bytes_needed > 0) return;
          result += String.fromCodePoint(code_point);
        });
      } else {
        buffer.forEach((v)=>{
          if (this.ascii && v > 0xFF) {
            if (this.fatal) throw new TypeError('invalid encoding');
            result += '?';
          } else if (v > 0xFFFF) {
            if (this.fatal) throw new TypeError('invalid encoding');
            result += '�';
          } else result += String.fromCodePoint(v);
        });
      }
      return result;
    }
  }
  if (typeof Opal.global.TextDecoder === "undefined") Opal.global.TextDecoder = Opal.generic_text_decoder;

  //
  // Sleep
  //
  // For modern platforms:
  $platform.sleep_atomics = (seconds)=>{
    return Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, Math.round(seconds * 1000));
  }
  // For older platforms, or when SharedArrayBuffer has been disabled:
  $platform.sleep_while = (seconds)=>{
    let get_time = Opal.global.performance ? ()=>performance.now() : ()=>new Date(),
        t = get_time();
    while (get_time() - t <= seconds * 1000);
  }

  //
  // Console
  //

  // Some platforms are missing console.warn, console.info or console.error; QuickJS, etc.
  if (typeof console.error === "undefined") console.error = console.log;
  if (typeof console.info === "undefined") console.info = console.log;
  if (typeof console.warn === "undefined") console.warn = console.log;

  //
  // OPAL_PLATFORM
  //

  Opal.const_set(Opal.Object, "OPAL_PLATFORM", $platform.name);

  return Opal;
})(Opal);
