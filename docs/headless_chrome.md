# Headless Chrome

## Requirements

First of all, make sure that you have Chrome at least 59.0 installed.
Also for now it's supported only on Mac and Linux. (version 60 may get support on Windows)

## Using the runner

To run your code using headless chrome, use `-R chrome` (`--runner chrome`) option:

    $ opal -Rchrome -e "puts 'Hello, Opal'"
    Hello, Opal

The runner also listens for any exceptions and prints formatted stracktraces back to your console:

    $ opal -Rchrome -e "
    def raising_method
      raise 'test error'
    end

    raising_method
    "

    RuntimeError : test error
        at $$raise (file:///tmp/chrome-opal.js:4996:6)
        at $$raising_method (file:///tmp/chrome-opal.js:21144:16)
        at  (file:///tmp/chrome-opal.js:21146:14)
        at  (file:///tmp/chrome-opal.js:21147:2)

## Using exit codes

By default headless chrome runner explicitely sets exit code to 1 when there was any error in the code.

    $ opal -Rchrome -e "42"; echo $?
    0

    $ opal -Rchrome -e "raise 'error'"; echo $?
    RuntimeError : error
        at $$raise (file:///tmp/chrome-opal.js:4996:6)
        at  (file:///tmp/chrome-opal.js:21139:14)
        at  (file:///tmp/chrome-opal.js:21140:2)
    1

You can change final exit code by using `Kernel#exit`, but make sure to require `opal/platform` in your code.

    $ opal -Rchrome -ropal/platform -e "exit(0)"; echo $?
    0

    $ opal -Rchrome -ropal/platform -e "exit(1)"; echo $?
    1

Also `Kernel#exit` doesn't abort your script. It simply takes the value that was passed to the first
invocation and persists it in `window.OPAL_EXIT_CODE`. Later headless chrome runner extracts it from the chrome runtime.

## Known limitations

1. `exit` doesn't abort you script (but `raise/throw` does)
2. When you call `console.log(one, two, three)` from your code headless chrome prints only the first passed object.
   The reason behind it is the format of the message that chrome sends to the runner.
   Opal intentionally uses a simplified method from Chrome API (`Console.messageAdded`) to catch `console.log` invocations.
   (Check lib/opal/cli_runners/chrome.js do get more information)

## Internals

Under the hood when you call `opal -Rchrome -e 'your code'` Opal uses chrome runner that is defined in
`lib/opal/cli_runners/chrome.rb`. This runner tries to connect to `localhost:9222` (9222 is a default port for a headless chrome server)
or runs the server on its own. It detects your platform and uses a default path to the chrome executable
(`Opal::CliRunners::Chrome#chrome_executable`) but you can override it by specifying `GOOGLE_CHROME_BINARY` environment
variable.

When the server is up and running it passes compiled js code to `node lib/opal/cli_runners/chrome.js`
as a plain input using stdin (basically, it's a second part of the runner).
`chrome.js` is a node js script that does the main job. It runs any provided code on the running chrome server,
catches errors and forwards console messages.


Moreover, you can actually call any js using headless chrome by running

      $ echo "console.log('Hello, Opal')" | node lib/opal/cli_runners/chrome.js

NOTE: to run it you need to have a chrome server running on `localhost:9222` (usually `chrome.rb` does it for you)

      $ chrome --disable-gpu --headless --remote-debugging-port=9222
