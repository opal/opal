# Headless Chrome

## Requirements

First of all, make sure that you have Chrome at least 59.0 installed.

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

    RuntimeError: test error
      from <internal:corelib/…>:2693:7:in `<main>'
      from -e:1:1:in `undefined'

## Using exit codes

By default headless chrome runner explicitly sets exit code to 1 when there was any error in the code.

    $ opal -Rchrome -e "42"; echo $?
    0

    $ opal -Rchrome -e "raise 'error'"; echo $?
    RuntimeError: error
      from <internal:corelib/kerne…>:2693:7:in `<main>'
      from -e:1:1:in `undefined'
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
   (Check `lib/opal/cli_runners/chrome.js` do get more information)

## Internals

Under the hood when you call `opal -Rchrome -e 'your code'` Opal uses chrome runner that is defined in
`lib/opal/cli_runners/chrome.rb`. This runner tries to connect to `localhost:9222` (9222 is a default port for a headless chrome server)
or runs the server on its own. It detects your platform and uses a default path to the chrome executable
(`Opal::CliRunners::Chrome#chrome_executable`) but you can override it by specifying `GOOGLE_CHROME_BINARY` environment
variable.

When the server is up and running it passes compiled js code to `lib/opal/cli_runners/chrome_cdp_interface.rb`
as a plain input using stdin (basically, it's a second part of the runner).
`chrome_cdp_interface.rb` is a node js + Opal script that does the main job. It runs any provided code on the running chrome server,
catches errors and forwards console messages.


## Using a remote chrome server

If you want to change a default chrome port or your chrome server is running on a different host:port
you can override default values by specifying `CHROME_HOST` and `CHROME_PORT` environment variables:

      $ CHROME_HOST=10.10.10.10 CHROME_PORT=8080 opal -Rchrome -e "puts 42"
      Connecting to 10.10.10.10:8080...
      42

NOTE: `CHROME_HOST` requires a chrome server to be started. You can't start remotely a server on a different host.


## Additional options

If you need to pass additional CLI options to the Chrome executable you can do so by setting the `CHROME_OPTS` environment variable:

      $ CHROME_OPTS="--window-size=412,732" opal -Rchrome -e "puts 42"
      42

Docker users may need `CHROME_OPTS="--no-sandbox"` due to the user namespaces limitations.

_For a list of additional options see https://developers.google.com/web/updates/2017/04/headless-chrome_
