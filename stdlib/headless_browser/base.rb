# backtick_javascript: true

%x{
  // Inhibit the default exit behavior
  window.OPAL_EXIT_CODE = "noexit";

  Opal.exit = function(code) {
    // The first call to Opal.exit should save an exit code.
    // All next invocations must be ignored.
    // Then we send an event to Chrome CDP Interface that we are finished

    if (window.OPAL_EXIT_CODE === "noexit") {
      window.OPAL_EXIT_CODE = code;
      window.alert("opalheadlessbrowserexit");
    }
  }
}
