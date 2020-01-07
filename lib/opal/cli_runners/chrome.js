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
    "<meta charset='utf-8'>" +
  "</head>" +
  "<body>" +
    "<script src='./chrome-opal.js'></script>" +
  "</body>" +
  "</html>"
);

var options = {
  host: process.env.CHROME_HOST || 'localhost',
  port: process.env.CHROME_PORT || 9222
};

CDP(options, function(client) {
  var Page = client.Page,
      Runtime = client.Runtime,
      Console = client.Console;

  Promise.all([
    Console.enable(),
    Page.enable(),
    Runtime.enable(),
  ]).then(function() {
    // This hook catches only the first argument of `console.log`
    // More advanced version Runtime.consoleAPICalled returns all arguments
    // but all of them are not formatted, i.e. by calling
    //   console.log('string', [1, 2, 3], {a: 'b'})
    // it returns the following data to the callback:
    //   {
    //     "type":"log",
    //     "args":[
    //       {
    //         "type":"string",
    //         "value":"string"
    //       },
    //       {
    //         "type":"object",
    //         "subtype":"array",
    //         "className":"Array",
    //         "description":"Array(3)",
    //         "objectId":"{\"injectedScriptId\":11,\"id\":1}",
    //         "preview":{
    //           "type":"object",
    //           "subtype":"array",
    //           "description":"Array(3)",
    //           "overflow":false,
    //           "properties":[
    //             {"name":"0","type":"number","value":"1"},
    //             {"name":"1","type":"number","value":"2"},
    //             {"name":"2","type":"number","value":"3"}
    //           ]
    //         }
    //       },
    //       {
    //         "type":"object",
    //         "className":"Object",
    //         "description":"Object",
    //         "objectId":"{\"injectedScriptId\":11,\"id\":2}",
    //         "preview":{
    //           "type":"object",
    //           "description":"Object",
    //           "overflow":false,
    //           "properties":[
    //             {"name":"a","type":"string","value":"b"}
    //           ]
    //         }
    //       }
    //     ],
    //     // ...
    //   }
    // Supporting this format for complex data structure is challenging, feel free to contribute!
    //
    Console.messageAdded(function(console_message) {
      process.stdout.write(console_message.message.text);
    });

    Runtime.exceptionThrown(function(exception) {
      var exceptionDetails = exception.exceptionDetails,
          properties = exceptionDetails.exception.preview.properties,
          stackTrace = exceptionDetails.stackTrace ? exceptionDetails.stackTrace.callFrames : [],
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

        console.log("    at " + raw.functionName + " (" + raw.url + ":" + raw.lineNumber + ":" + raw.columnNumber + ")")
      }

      process.exit(1);
    })

    Page.loadEventFired(() => {
      Runtime.evaluate({ expression: "window.OPAL_EXIT_CODE" }).then(function(output) {
        client.close();

        if (typeof(output.result) !== "undefined" && output.result.type === "number") {
          process.exit(output.result.value);
        } else {
          process.exit(0);
        }
      })
    });

    Page.navigate({ url: 'file:///tmp/chrome-opal.html' })
  });
});
