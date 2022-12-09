# frozen_string_literal: true

# This script I converted into Opal, so that I don't have to write
# buffer handling again. We have gets, Node has nothing close to it,
# even async.
# For CDP see docs/cdp_common.(md|json)

require 'opal/platform'
require 'nodejs/env'

%x{
var CDP = require("chrome-remote-interface");
var fs = require("fs");
var http = require("http");

var dir = #{ARGV.last};
// var ext = #{ENV['OPAL_CDP_EXT']}; // not used at the moment
var offset; // port offset for http server, depending on number of targets

// even though its Firefox, "chrome-remote-interface" expects CHROME_* vars
var options = {
  host: #{ENV['CHROME_HOST'] || 'localhost'},
  port: parseInt(#{ENV['CHROME_PORT'] || '9333'}) // makes sure it doesn't accidentally connect to a lingering chrome
};

// support functions

function perror(error) { console.error(error); }

var exiting = false;

function shutdown(exit_code) {
  if (exiting) { return Promise.resolve(); }
  exiting = true;
  cdp_client.Target.closeTarget(target_id); // Promise doesn't get resolved
  server.close();
  process.exit(exit_code);
};

// simple HTTP server to deliver page, scripts to, and trigger commands from browser

function not_found(res) {
  res.writeHead(404, { "Content-Type": "text/plain" });
  res.end("NOT FOUND");
}

function response_ok(res) {
  res.writeHead(200, { "Content-Type": "text/plain" });
  res.end("OK");
}

function handle_post(req, res, fun) {
  var data = "";
  req.on('data', function(chunk) {
    data += chunk;
  })
  req.on('end', function() {
    var obj = JSON.parse(data);
    fun.call(this, obj);
  });
}

var server = http.createServer(function(req, res) {
  if (req.method === "GET") {
    var path = dir + '/' + req.url.slice(1);
    if (path.includes('..') || !fs.existsSync(path)) {
      not_found(res);
    } else {
      var content_type;
      if (path.endsWith(".html")) {
        content_type = "text/html"
      } else if (path.endsWith(".map")) {
        content_type = "application/json"
      } else {
        content_type = "application/javascript"
      }
      res.writeHead(200, { "Content-Type": content_type });
      res.end(fs.readFileSync(path));
    }
  } else if (req.method === "POST") {
    if (req.url === "/File.write") {
      // totally insecure on purpose
      handle_post(req, res, function(obj) {
        fs.writeFileSync(obj.filename, obj.data);
        response_ok(res);
      });
    } else {
      not_found(res);
    }
  } else {
    not_found(res);
  }
});

// actual CDP code

CDP.List(options, function(err, targets) {
  offset = targets ? targets.length + 1 : 1;

  return CDP(options, function(browser_client) {

    server.listen({port: offset + options.port, host: options.host });

    browser_client.Target.createTarget({url: "about:blank"}).then(function(target) {
      target_id = target;
      options.target = target_id.targetId;

      CDP(options, function(client) {
        cdp_client = client;

        var Log = client.Log,
            Page = client.Page,
            Runtime = client.Runtime;

        // enable used CDP domains
        Promise.all([
          Log.enable(),
          Page.enable(),
          Runtime.enable()
        ]).then(function() {

          // receive and handle all kinds of log and console messages
          Log.entryAdded(function(entry) {
            process.stdout.write(entry.entry.level + ': ' + entry.entry.text + "\n");
          });

          Runtime.consoleAPICalled(function(entry) {
            var args = entry.args;
            var stack = null;
            var i, arg, frame, value;

            // output actual message
            for(i = 0; i < args.length; i++) {
              arg = args[i];
              if (arg.type === "string") { value = arg.value; }
              else { value = JSON.stringify(arg); }
              process.stdout.write(value);
            }

            if (entry.stackTrace && entry.stackTrace.callFrames) { stack = entry.stackTrace.callFrames; }
            if (entry.type === "error" && stack) {
              // print full stack for errors
              process.stdout.write("\n");
              for(i = 0; i < stack.length; i++) {
                frame = stack[i];
                if (frame) {
                  value = frame.url + ':' + frame.lineNumer + ':' + frame.columnNumber + '\n';
                  process.stdout.write(value);
                }
              }
            }
          });

          Runtime.exceptionThrown(function(exception) {
            var ex = exception.exceptionDetails;
            var stack = ex.stackTrace.callFrames;
            var fr;
            perror(ex.url + ':' + ex.lineNumber + ':' + ex.columnNumber + ': ' + ex.text);
            for (var i = 0; i < stack.length; i++) {
              fr = stack[i];
              perror(fr.url + ':' + fr.lineNumber + ':' + fr.columnNumber + ': in ' + fr.functionName);
            }
            return shutdown(1);
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
              elsif `dialog.type` == 'alert' && `dialog.message` == 'opalheadlessbrowserexit'
                # A special case of an alert with a magic string "opalheadlessbrowserexit".
                # This denotes that `Kernel#exit` has been called. We would have rather used
                # an exception here, but they don't bubble sometimes.
                %x{
                  Page.handleJavaScriptDialog({accept: true});
                  Runtime.evaluate({ expression: "window.OPAL_EXIT_CODE" }).then(function(output) {
                    var exit_code = 0;
                    if (typeof(output.result) !== "undefined" && output.result.type === "number") {
                      exit_code = output.result.value;
                    }
                    return shutdown(exit_code);
                  });
                }
              end
            }
          });

          Page.loadEventFired(() => {
            Runtime.evaluate({ expression: "window.OPAL_EXIT_CODE" }).then(function(output) {
              if (typeof(output.result) !== "undefined" && output.result.type === "number") {
                return shutdown(output.result.value);
              } else if (typeof(output.result) !== "undefined" && output.result.type === "string" && output.result.value === "noexit") {
                // do nothing, we have headless chrome support enabled and there are most probably async events awaiting
              } else {
                return shutdown(0);
              }
            })
          });

          Page.navigate({ url: "http://localhost:" + (offset + options.port).toString() + "/index.html" })
        });
      });
    });
  });
});
}
# end of code (marker to help see if brackets match above)
