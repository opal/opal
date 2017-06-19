var CDP = require("chrome-remote-interface");
var fs = require("fs");

// NOTE: the code above doesn't work on Windows
// and it doesn't support interactive stdin input (which is ok for our scenario)
var opal_code = fs.readFileSync("/dev/stdin").toString();

// Chrome can't handle huge data passed to `addScriptToEvaluateOnLoad`
// https://groups.google.com/a/chromium.org/forum/#!topic/chromium-discuss/U5qyeX_ydBo
// The only way is to create temporary files and pass them to chrome.
fs.writeFileSync("/tmp/chrome-opal.js", opal_code);
fs.writeFileSync("/tmp/chrome-opal.html", "" +
  "<html>" +
  "<head>" +
    "<script src='chrome-opal.js'></script>" +
  "</head>" +
  "<body>" +
  "</body>" +
  "</html>"
)

CDP(function(client) {
  var Page = client.Page,
      Runtime = client.Runtime,
      Console = client.Console;

  Promise.all([
    Console.enable(),
    Page.enable(),
    Runtime.enable(),
  ]).then(function() {
    var no_errors = true;

    Console.messageAdded(function(console_message) {
      process.stdout.write(console_message.message.text);
    });

    Runtime.exceptionThrown(function(exception) {
      var exceptionDetails = exception.exceptionDetails,
          properties = exceptionDetails.exception.preview.properties,
          stackTrace = exceptionDetails.stackTrace.callFrames,
          name, message, trace = [], i;


      for (i = 0; i < properties.length; i++) {
        var property = properties[i];

        if (property.name == "name") {
          name = property.value;
        }

        if (property.name == "message") {
          message = property.value;
        }
      }

      console.log(name + " : " + message);

      for (i = 0; i < stackTrace.length; i++) {
        var raw = stackTrace[i];

        console.log("    at " + raw.functionName + " (" + raw.url + ":" + raw.lineNnumber + ":" + raw.columnNumber + ")")
      }

      no_errors = false;
    })

    Page.loadEventFired(() => {
      client.close();

      if (no_errors) {
        process.exit(0);
      } else {
        process.exit(1);
      }
    });

    Page.navigate({ url: 'file:///tmp/chrome-opal.html' })
  });
});
