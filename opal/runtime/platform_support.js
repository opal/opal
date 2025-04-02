(function(Opal) {
  "use strict";
  // Platform support
  // ----------------

  // Detect platform. Sets the Opal.platform object with the following keys:
  //   is_browser: set to true if the platform is a browser
  //   name:       string, name of the platform if detected or "unknown"
  //   tty:        set to true if platform supports tty, default false
  // Then additional keys for APIs are added to Opal.platform object in platform.js.
  var $platform = { is_browser: false, name: "unknown", tty: false };
  Opal.platform = $platform;

  // always the same across all platforms
  $platform.clock_realtime = function() { return Date.now(); };
  $platform.clock_monotonic = (typeof(Opal.global.performance) === "object") ? function() { return performance.now(); } : null;
  $platform.io_action = function(action, ...args) {
    // standard io helper function to raise correct Ruby Error instead of platform specific error
    try {
      return action(...args);
    } catch (error) {
      // Errno is autoloaded, to make sure it gets loaded eventually, must use const_get here
      if (Opal.Object.$const_get('Errno').$constants().indexOf(error.code) >= 0) {
        var error_class = Opal.Errno.$const_get(error.code);
        Opal.Kernel.$raise(error_class.$new(error.message));
      }
      Opal.Kernel.$raise(error);
    }
  };
  $platform.error_with_code = function(code) {
    let err = new Error();
    err.code = code;
    return err;
  }

  //
  // identify platform
  //

  // browsers and browser based app platforms
  if (typeof(document) === "object" && typeof navigator === "object" && typeof navigator.userAgent === "string") {
    var nav_ua = navigator.userAgent;
    if (nav_ua.indexOf("Firefox") >= 0) { $platform.name = "firefox"; }
    else if (nav_ua.indexOf("Chrome") >= 0) { $platform.name = "chrome" }
    else if (nav_ua.indexOf("Safari") >= 0) { $platform.name = "safari" }
    Opal.platform.is_browser = true;
  }
  else if (typeof(window) === "object" && typeof(GjsFileImporter) === "function") { $platform.name = "gjs"; }
  // all the server and desktop platforms
  else if (typeof(Bun) === "object" && Bun.version) { $platform.name = "bun"; }
  else if (typeof(Deno) === "object" && Deno.version?.deno) { $platform.name = "deno"; }
  else if (typeof(process) === "object" && process.versions?.node) {
    $platform.name = (typeof(Graal) === "object" && Graal.versionGraalVM) ? "graalnodejs" : "node";
  }
  // else if (typeof(Graal) === "object" && Graal.versionGraalVM) { $platform.name = "graaljs"; }
  else if (typeof(window) === "undefined" && typeof(__loadScript) !== "undefined") { $platform.name = "quickjs"; }
  else if (typeof(Automation) === "object" && typeof(Library) === "function" && typeof(ObjC) === "object") { $platform.name = "osascript"; }
  else if (typeof(opalminiracer) !== "undefined") { $platform.name = "mini_racer"; }

  Opal.exit = (status)=>{ console.log('Exited with status ' + status); };

  $platform.handle_unsupported_feature = function(message_obj) {
    let message = 'not implemented';
    if (message_obj && typeof(message_obj.is_mob) !== "undefined" && message_obj.is_mob) { message = message_obj.message; }
    switch (Opal.config.unsupported_features_severity) {
    case 'error':
      Opal.Kernel.$raise(Opal.NotImplementedError, message);
      break;
    case 'warning':
      console.warn(message);
      break;
    }
    // otherwise ignore
  }
  Opal.handle_unsupported_feature = $platform.handle_unsupported_feature;

  // set OPAL_PLATFORM
  Opal.const_set(Opal.Object, "OPAL_PLATFORM", $platform.name);

  return Opal;
})(Opal);
