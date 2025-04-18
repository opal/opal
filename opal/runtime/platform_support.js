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

  // Gnome GJS and Cinnamon CJS
  // IO is totally unstable, so do not detect them and use the generic driver for "unknown engine"
  // else if (typeof(window) === "object" && typeof(GjsFileImporter) === "function") { $platform.name = "gjs"; }

  // Graal, mabe one day in the future
  // else if (typeof(Graal) === "object" && Graal.versionGraalVM) { $platform.name = "graaljs"; }

  // QuickJS and QuickJS-ng
  else if (typeof(window) === "undefined" && typeof(std) === "object" && typeof(os) === "object") {
    $platform.name = "quickjs";
  }

  // Mini-Racer
  else if (typeof(opalminiracer) !== "undefined") { $platform.name = "mini_racer"; }

  Opal.exit = (status)=>{ console.log('Exited with status ' + status); };

  $platform.handle_unsupported_feature = function(message) {
    if (!message) message = "not implemented";
    switch (Opal.config.unsupported_features_severity) {
    case 'error':
      Opal.Kernel.$raise(Opal.NotImplementedError, message);
      break;
    case 'warning':
      console.warn(message.toString());
      break;
    }
    // otherwise ignore
  }

  // Shim if TextDecoder is missing; QuickJS, mini_racer, etc.
  // Completely 'transparent' to the actual encoding.
  if (typeof Opal.global.TextDecoder === "undefined") {
    Opal.global.TextDecoder = class {
      constructor(_label, _options) {}
      decode(buffer) {
        let result = '';
        if (buffer instanceof ArrayBuffer) buffer = new Uint8Array(ArrayBuffer.buffer); // fall back to ascii 8 bit
        // naturally uses buffers item bit width, which may or may not be the required codepoint bit width
        // so if utf16 uses Uint16Array, best case, all is fine, otherwise, e.g with Uint8, result may still be garbled
        buffer.forEach((v)=>{result += String.fromCodePoint(v)});
        return result;
      }
    }
  }

  // Some are missing console.warn, console.info or console.error; QuickJS, etc.
  if (typeof console.error === "undefined") console.error = console.log;
  if (typeof console.info === "undefined") console.info = console.log;
  if (typeof console.warn === "undefined") console.warn = console.log;

  // set OPAL_PLATFORM
  Opal.const_set(Opal.Object, "OPAL_PLATFORM", $platform.name);

  return Opal;
})(Opal);
