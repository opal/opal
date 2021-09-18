# This script I converted into Opal, so that I don't have to write
# buffer handling again. We have gets, Node has nothing close to it,
# even async.

require 'opal/platform'

%x{
var CDP = require("chrome-remote-interface");
var fs = require("fs");

var dir = #{ARGV[0]}

var options = {
  host: #{ENV['CHROME_HOST'] || 'localhost'},
  port: #{ENV['CHROME_PORT'] || 9222}
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
      var properties = exception.exceptionDetails.exception.preview.properties,
          stack, i;

      for (i = 0; i < properties.length; i++) {
        var property = properties[i];

        if (property.name == "stack") {
          stack = property.value;
        }
      }

      console.log(stack);

      process.exit(1);
    });

    Page.javascriptDialogOpening((dialog) => {
      #{
        if `dialog.type` == 'prompt'
          message = gets&.chomp
          if message
            `Page.handleJavaScriptDialog({accept: true, promptText: #{message}})`
          else
            `Page.handleJavaScriptDialog({accept: false})`
          end
        end
      }
    });

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

    Page.navigate({ url: "file://"+dir+"/index.html" })
  });
});
}