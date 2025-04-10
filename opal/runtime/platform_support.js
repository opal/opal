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
  else if (typeof(Bun) === "object" && Bun.version) { $platform.name = "bun"; }
  else if (typeof(Deno) === "object" && Deno.version?.deno) { $platform.name = "deno"; }
  else if (typeof(process) === "object" && process.versions?.node) {
    $platform.name = (typeof(Graal) === "object" && Graal.versionGraalVM) ? "graalnodejs" : "node";
  }

  // Gnome GJS and Cinnamon CJS
  else if (typeof(window) === "object" && typeof(GjsFileImporter) === "function") { $platform.name = "gjs"; }

  // Graal, mabe one day in the future
  // else if (typeof(Graal) === "object" && Graal.versionGraalVM) { $platform.name = "graaljs"; }

  // QuickJS and QuickJS-ng
  else if (typeof(window) === "undefined" && typeof(std) === "object" && typeof(os) === "object") {
    $platform.name = "quickjs";
  }

  // Apple macOS osascript
  else if (typeof(Automation) === "object" && typeof(Library) === "function" && typeof(ObjC) === "object") {
    $platform.name = "osascript";
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

  // set OPAL_PLATFORM
  Opal.const_set(Opal.Object, "OPAL_PLATFORM", $platform.name);

  return Opal;
})(Opal);
