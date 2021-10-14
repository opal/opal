# use_strict: true
# frozen_string_literal: true

%x{
  Opal.exit = function(code) {
    // You can't exit from the browser.
    // The first call to Opal.exit should save an exit code.
    // All next invocations must be ignored.

    if (typeof(window.OPAL_EXIT_CODE) === "undefined") {
      window.OPAL_EXIT_CODE = code;
    }
  }
}
