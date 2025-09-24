# chrome-remote-interface

[![CI status](https://github.com/cyrus-and/chrome-remote-interface/actions/workflows/ci.yml/badge.svg)](https://github.com/cyrus-and/chrome-remote-interface/actions?query=workflow:CI)

[Chrome Debugging Protocol] interface that helps to instrument Chrome (or any
other suitable [implementation](#implementations)) by providing a simple
abstraction of commands and notifications using a straightforward JavaScript
API.

## Sample API usage

The following snippet loads `https://github.com` and dumps every request made:

```js
const CDP = require('chrome-remote-interface');

async function example() {
    let client;
    try {
        // connect to endpoint
        client = await CDP();
        // extract domains
        const {Network, Page} = client;
        // setup handlers
        Network.requestWillBeSent((params) => {
            console.log(params.request.url);
        });
        // enable events then start!
        await Network.enable();
        await Page.enable();
        await Page.navigate({url: 'https://github.com'});
        await Page.loadEventFired();
    } catch (err) {
        console.error(err);
    } finally {
        if (client) {
            await client.close();
        }
    }
}

example();
```

Find more examples in the [wiki]. You may also want to take a look at the [FAQ].

[wiki]: https://github.com/cyrus-and/chrome-remote-interface/wiki
[async-await-example]: https://github.com/cyrus-and/chrome-remote-interface/wiki/Async-await-example
[FAQ]: https://github.com/cyrus-and/chrome-remote-interface#faq

## Installation

    npm install chrome-remote-interface

Install globally (`-g`) to just use the [bundled client](#bundled-client).

## Implementations

This module should work with every application implementing the
[Chrome Debugging Protocol]. In particular, it has been tested against the
following implementations:

Implementation             | Protocol version   | [Protocol] | [List] | [New] | [Activate] | [Close] | [Version]
---------------------------|--------------------|------------|--------|-------|------------|---------|-----------
[Chrome][1.1]              | [tip-of-tree][1.2] | yes¹       | yes    | yes   | yes        | yes     | yes
[Opera][2.1]               | [tip-of-tree][2.2] | yes        | yes    | yes   | yes        | yes     | yes
[Node.js][3.1] ([v6.3.0]+) | [node][3.2]        | yes        | no     | no    | no         | no      | yes
[Safari (iOS)][4.1]        | [*partial*][4.2]   | no         | yes    | no    | no         | no      | no
[Edge][5.1]                | [*partial*][5.2]   | yes        | yes    | no    | no         | no      | yes
[Firefox (Nightly)][6.1]   | [*partial*][6.2]   | yes        | yes    | no    | yes        | yes     | yes

¹ Not available on [Chrome for Android][chrome-mobile-protocol], hence a local version of the protocol must be used.

[chrome-mobile-protocol]: https://bugs.chromium.org/p/chromium/issues/detail?id=824626#c4

[1.1]: #chromechromium
[1.2]: https://chromedevtools.github.io/devtools-protocol/tot/

[2.1]: #opera
[2.2]: https://chromedevtools.github.io/devtools-protocol/tot/

[3.1]: #nodejs
[3.2]: https://chromedevtools.github.io/devtools-protocol/v8/

[4.1]: #safari-ios
[4.2]: http://trac.webkit.org/browser/trunk/Source/JavaScriptCore/inspector/protocol

[5.1]: #edge
[5.2]: https://docs.microsoft.com/en-us/microsoft-edge/devtools-protocol/0.1/domains/

[6.1]: #firefox-nightly
[6.2]: https://firefox-source-docs.mozilla.org/remote/index.html

[v6.3.0]: https://nodejs.org/en/blog/release/v6.3.0/

[Protocol]: #cdpprotocoloptions-callback
[List]: #cdplistoptions-callback
[New]: #cdpnewoptions-callback
[Activate]: #cdpactivateoptions-callback
[Close]: #cdpcloseoptions-callback
[Version]: #cdpversionoptions-callback

The meaning of *target* varies according to the implementation, for example,
each Chrome tab represents a target whereas for Node.js a target is the
currently inspected script.

## Setup

An instance of either Chrome itself or another implementation needs to be
running on a known port in order to use this module (defaults to
`localhost:9222`).

### Chrome/Chromium

#### Desktop

Start Chrome with the `--remote-debugging-port` option, for example:

    google-chrome --remote-debugging-port=9222

##### Headless

Since version 59, additionally use the `--headless` option, for example:

    google-chrome --headless --remote-debugging-port=9222

#### Android

Plug the device and make sure to authorize the connection from the device itself. Then
enable the port forwarding, for example:

    adb -d forward tcp:9222 localabstract:chrome_devtools_remote

After that you should be able to use `http://127.0.0.1:9222` as usual, but note that in
Android, Chrome does not have its own protocol available, so a local version must be used.
See [here](#chrome-debugging-protocol-versions) for more information.

##### WebView

In order to be inspectable, a WebView must
be [configured for debugging][webview] and the corresponding process ID must be
known. There are several ways to obtain it, for example:

    adb shell grep -a webview_devtools_remote /proc/net/unix

Finally, port forwarding can be enabled as follows:

    adb forward tcp:9222 localabstract:webview_devtools_remote_<pid>

[webview]: https://developers.google.com/web/tools/chrome-devtools/remote-debugging/webviews#configure_webviews_for_debugging

### Opera

Start Opera with the `--remote-debugging-port` option, for example:

    opera --remote-debugging-port=9222

### Node.js

Start Node.js with the `--inspect` option, for example:

    node --inspect=9222 script.js

### Safari (iOS)

Install and run the [iOS WebKit Debug Proxy][iwdp]. Then use it with the `local`
option set to `true` to use the local version of the protocol or pass a custom
descriptor upon connection (`protocol` option).

[iwdp]: https://github.com/google/ios-webkit-debug-proxy

### Edge

Start Edge with the `--devtools-server-port` option, for example:

    MicrosoftEdge.exe --devtools-server-port 9222 about:blank

Please find more information [here][edge-devtools].

[edge-devtools]: https://docs.microsoft.com/en-us/microsoft-edge/devtools-protocol/

### Firefox (Nightly)

Start Firefox with the `--remote-debugging-port` option, for example:

    firefox --remote-debugging-port 9222

Bear in mind that this is an experimental feature of Firefox.

## Bundled client

This module comes with a bundled client application that can be used to
interactively control a remote instance.

### Target management

The bundled client exposes subcommands to interact with the HTTP frontend
(e.g., [List](#cdplistoptions-callback), [New](#cdpnewoptions-callback), etc.),
run with `--help` to display the list of available options.

Here are some examples:

```js
$ chrome-remote-interface new 'http://example.com'
{
    "description": "",
    "devtoolsFrontendUrl": "/devtools/inspector.html?ws=localhost:9222/devtools/page/b049bb56-de7d-424c-a331-6ae44cf7ae01",
    "id": "b049bb56-de7d-424c-a331-6ae44cf7ae01",
    "thumbnailUrl": "/thumb/b049bb56-de7d-424c-a331-6ae44cf7ae01",
    "title": "",
    "type": "page",
    "url": "http://example.com/",
    "webSocketDebuggerUrl": "ws://localhost:9222/devtools/page/b049bb56-de7d-424c-a331-6ae44cf7ae01"
}
$ chrome-remote-interface close 'b049bb56-de7d-424c-a331-6ae44cf7ae01'
```

### Inspection

Using the `inspect` subcommand it is possible to perform [command execution](#clientdomainmethodparams-callback)
and [event binding](#clientdomaineventcallback) in a REPL fashion that provides completion.

Here is a sample session:

```js
$ chrome-remote-interface inspect
>>> Runtime.evaluate({expression: 'window.location.toString()'})
{ result: { type: 'string', value: 'about:blank' } }
>>> Page.enable()
{}
>>> Page.loadEventFired(console.log)
[Function]
>>> Page.navigate({url: 'https://github.com'})
{ frameId: 'E1657E22F06E6E0BE13DFA8130C20298',
  loaderId: '439236ADE39978F98C20E8939A32D3A5' }
>>> { timestamp: 7454.721299 } // from Page.loadEventFired
>>> Runtime.evaluate({expression: 'window.location.toString()'})
{ result: { type: 'string', value: 'https://github.com/' } }
```

Additionally there are some custom commands available:

```js
>>> .help
[...]
.reset    Remove all the registered event handlers
.target   Display the current target
```

## Embedded documentation

In both the REPL and the regular API every object of the protocol is *decorated*
with the meta information found within the descriptor. In addition The
`category` field is added, which determines if the member is a `command`, an
`event` or a `type`.

For example to learn how to call `Page.navigate`:

```js
>>> Page.navigate
{ [Function]
  category: 'command',
  parameters: { url: { type: 'string', description: 'URL to navigate the page to.' } },
  returns:
   [ { name: 'frameId',
       '$ref': 'FrameId',
       hidden: true,
       description: 'Frame id that will be navigated.' } ],
  description: 'Navigates current page to the given URL.',
  handlers: [ 'browser', 'renderer' ] }
```

To learn about the parameters returned by the `Network.requestWillBeSent` event:

```js
>>> Network.requestWillBeSent
{ [Function]
  category: 'event',
  description: 'Fired when page is about to send HTTP request.',
  parameters:
   { requestId: { '$ref': 'RequestId', description: 'Request identifier.' },
     frameId:
      { '$ref': 'Page.FrameId',
        description: 'Frame identifier.',
        hidden: true },
     loaderId: { '$ref': 'LoaderId', description: 'Loader identifier.' },
     documentURL:
      { type: 'string',
        description: 'URL of the document this request is loaded for.' },
     request: { '$ref': 'Request', description: 'Request data.' },
     timestamp: { '$ref': 'Timestamp', description: 'Timestamp.' },
     wallTime:
      { '$ref': 'Timestamp',
        hidden: true,
        description: 'UTC Timestamp.' },
     initiator: { '$ref': 'Initiator', description: 'Request initiator.' },
     redirectResponse:
      { optional: true,
        '$ref': 'Response',
        description: 'Redirect response data.' },
     type:
      { '$ref': 'Page.ResourceType',
        optional: true,
        hidden: true,
        description: 'Type of this resource.' } } }
```

To inspect the `Network.Request` (note that unlike commands and events, types
are named in upper camel case) type:

```js
>>> Network.Request
{ category: 'type',
  id: 'Request',
  type: 'object',
  description: 'HTTP request data.',
  properties:
   { url: { type: 'string', description: 'Request URL.' },
     method: { type: 'string', description: 'HTTP request method.' },
     headers: { '$ref': 'Headers', description: 'HTTP request headers.' },
     postData:
      { type: 'string',
        optional: true,
        description: 'HTTP POST request data.' },
     mixedContentType:
      { optional: true,
        type: 'string',
        enum: [Object],
        description: 'The mixed content status of the request, as defined in http://www.w3.org/TR/mixed-content/' },
     initialPriority:
      { '$ref': 'ResourcePriority',
        description: 'Priority of the resource request at the time request is sent.' } } }
```

## Chrome Debugging Protocol versions

By default `chrome-remote-interface` *asks* the remote instance to provide its
own protocol.

This behavior can be changed by setting the `local` option to `true`
upon [connection](#cdpoptions-callback), in which case the [local version] of
the protocol descriptor is used. This file is manually updated from time to time
using `scripts/update-protocol.sh` and pushed to this repository.

To further override the above behavior there are basically two options:

- pass a custom protocol descriptor upon [connection](#cdpoptions-callback)
  (`protocol` option);

- use the *raw* version of the [commands](#clientsendmethod-params-callback)
  and [events](#event-domainmethod) interface to use bleeding-edge features that
  do not appear in the [local version] of the protocol descriptor;

[local version]: lib/protocol.json

## Browser usage

This module is able to run within a web context, with obvious limitations
though, namely external HTTP requests
([List](#cdplistoptions-callback), [New](#cdpnewoptions-callback), etc.) cannot
be performed directly, for this reason the user must provide a global
`criRequest` in order to use them:

```js
function criRequest(options, callback) {}
```

`options` is the same object used by the Node.js `http` module and `callback` is
a function taking two arguments: `err` (JavaScript `Error` object or `null`) and
`data` (string result).

### Using [webpack](https://webpack.github.io/)

It just works, simply require this module:

```js
const CDP = require('chrome-remote-interface');
```

### Using *vanilla* JavaScript

To generate a JavaScript file that can be used with a `<script>` element:

1. run `npm install` from the root directory;

2. manually run webpack with:

        TARGET=var npm run webpack

3. use as:

    ```html
    <script>
      function criRequest(options, callback) { /*...*/ }
    </script>
    <script src="chrome-remote-interface.js"></script>
    ```

## TypeScript Support

[TypeScript][] definitions are kindly provided by [Khairul Azhar Kasmiran][] and [Seth Westphal][], and can be installed from [DefinitelyTyped][]:

```
npm install --save-dev @types/chrome-remote-interface
```

Note that the TypeScript definitions are automatically generated from the npm package `devtools-protocol@0.0.927104`. For other versions of devtools-protocol:

1. Install patch-package using [the instructions given](https://github.com/ds300/patch-package#set-up).
2. Copy the contents of the corresponding https://github.com/ChromeDevTools/devtools-protocol/tree/master/types folder (according to commit) into `node_modules/devtools-protocol/types`.
3. Run `npx patch-package devtools-protocol` so that the changes persist across an `npm install`.

[TypeScript]: https://www.typescriptlang.org/
[Khairul Azhar Kasmiran]: https://github.com/kazarmy
[Seth Westphal]: https://github.com/westy92
[DefinitelyTyped]: https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/chrome-remote-interface

## API

The API consists of three parts:

- *DevTools* methods (for those [implementations](#implementations) that support
  them, e.g., [List](#cdplistoptions-callback), [New](#cdpnewoptions-callback),
  etc.);

- [connection](#cdpoptions-callback) establishment;

- the actual [protocol interaction](#class-cdp).

### CDP([options], [callback])

Connects to a remote instance using the [Chrome Debugging Protocol].

`options` is an object with the following optional properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function;
- `target`: determines which target this client should attach to. The behavior
  changes according to the type:

  - a `function` that takes the array returned by the `List` method and returns
    a target or its numeric index relative to the array;
  - a target `object` like those returned by the `New` and `List` methods;
  - a `string` representing the raw WebSocket URL, in this case `host` and
    `port` are not used to fetch the target list, yet they are used to complete
    the URL if relative;
  - a `string` representing the target id.

  Defaults to a function which returns the first available target according to
  the implementation (note that at most one connection can be established to the
  same target);
- `protocol`: [Chrome Debugging Protocol] descriptor object. Defaults to use the
  protocol chosen according to the `local` option;
- `local`: a boolean indicating whether the protocol must be fetched *remotely*
  or if the local version must be used. It has no effect if the `protocol`
  option is set. Defaults to `false`.

These options are also valid properties of all the instances of the `CDP`
class. In addition to that, the `webSocketUrl` field contains the currently used
WebSocket URL.

`callback` is a listener automatically added to the `connect` event of the
returned `EventEmitter`. When `callback` is omitted a `Promise` object is
returned which becomes fulfilled if the `connect` event is triggered and
rejected if the `error` event is triggered.

The `EventEmitter` supports the following events:

#### Event: 'connect'

```js
function (client) {}
```

Emitted when the connection to the WebSocket is established.

`client` is an instance of the `CDP` class.

#### Event: 'error'

```js
function (err) {}
```

Emitted when `http://host:port/json` cannot be reached or if it is not possible
to connect to the WebSocket.

`err` is an instance of `Error`.

### CDP.Protocol([options], [callback])

Fetch the [Chrome Debugging Protocol] descriptor.

`options` is an object with the following optional properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function;
- `local`: a boolean indicating whether the protocol must be fetched *remotely*
  or if the local version must be returned. Defaults to `false`.

`callback` is executed when the protocol is fetched, it gets the following
arguments:

- `err`: a `Error` object indicating the success status;
- `protocol`: the [Chrome Debugging Protocol] descriptor.

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.Protocol((err, protocol) => {
    if (!err) {
        console.log(JSON.stringify(protocol, null, 4));
    }
});
```

### CDP.List([options], [callback])

Request the list of the available open targets/tabs of the remote instance.

`options` is an object with the following optional properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function.

`callback` is executed when the list is correctly received, it gets the
following arguments:

- `err`: a `Error` object indicating the success status;
- `targets`: the array returned by `http://host:port/json/list` containing the
  target list.

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.List((err, targets) => {
    if (!err) {
        console.log(targets);
    }
});
```

### CDP.New([options], [callback])

Create a new target/tab in the remote instance.

`options` is an object with the following optional properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function;
- `url`: URL to load in the new target/tab. Defaults to `about:blank`.

`callback` is executed when the target is created, it gets the following
arguments:

- `err`: a `Error` object indicating the success status;
- `target`: the object returned by `http://host:port/json/new` containing the
  target.

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.New((err, target) => {
    if (!err) {
        console.log(target);
    }
});
```

### CDP.Activate([options], [callback])

Activate an open target/tab of the remote instance.

`options` is an object with the following properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function;
- `id`: Target id. Required, no default.

`callback` is executed when the response to the activation request is
received. It gets the following arguments:

- `err`: a `Error` object indicating the success status;

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.Activate({id: 'CC46FBFA-3BDA-493B-B2E4-2BE6EB0D97EC'}, (err) => {
    if (!err) {
        console.log('target is activated');
    }
});
```

### CDP.Close([options], [callback])

Close an open target/tab of the remote instance.

`options` is an object with the following properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function;
- `id`: Target id. Required, no default.

`callback` is executed when the response to the close request is received. It
gets the following arguments:

- `err`: a `Error` object indicating the success status;

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.Close({id: 'CC46FBFA-3BDA-493B-B2E4-2BE6EB0D97EC'}, (err) => {
    if (!err) {
        console.log('target is closing');
    }
});
```

Note that the callback is fired when the target is *queued* for removal, but the
actual removal will occur asynchronously.

### CDP.Version([options], [callback])

Request version information from the remote instance.

`options` is an object with the following optional properties:

- `host`: HTTP frontend host. Defaults to `localhost`;
- `port`: HTTP frontend port. Defaults to `9222`;
- `secure`: HTTPS/WSS frontend. Defaults to `false`;
- `useHostName`: do not perform a DNS lookup of the host. Defaults to `false`;
- `alterPath`: a `function` taking and returning the path fragment of a URL
  before that a request happens. Defaults to the identity function.

`callback` is executed when the version information is correctly received, it
gets the following arguments:

- `err`: a `Error` object indicating the success status;
- `info`: a JSON object returned by `http://host:port/json/version` containing
  the version information.

When `callback` is omitted a `Promise` object is returned.

For example:

```js
const CDP = require('chrome-remote-interface');
CDP.Version((err, info) => {
    if (!err) {
        console.log(info);
    }
});
```

### Class: CDP

#### Event: 'event'

```js
function (message) {}
```

Emitted when the remote instance sends any notification through the WebSocket.

`message` is the object received, it has the following properties:

- `method`: a string describing the notification (e.g.,
  `'Network.requestWillBeSent'`);
- `params`: an object containing the payload;
- `sessionId`: an optional string representing the session identifier.

Refer to the [Chrome Debugging Protocol] specification for more information.

For example:

```js
client.on('event', (message) => {
    if (message.method === 'Network.requestWillBeSent') {
        console.log(message.params);
    }
});
```

#### Event: '`<domain>`.`<method>`'

```js
function (params, sessionId) {}
```

Emitted when the remote instance sends a notification for `<domain>.<method>`
through the WebSocket.

`params` is an object containing the payload.

`sessionId` is an optional string representing the session identifier.

This is just a utility event which allows to easily listen for specific
notifications (see [`'event'`](#event-event)), for example:

```js
client.on('Network.requestWillBeSent', console.log);
```

Additionally, the equivalent `<domain>.on('<method>', ...)` syntax is available, for example:

```js
client.Network.on('requestWillBeSent', console.log);
```

#### Event: '`<domain>`.`<method>`.`<sessionId>`'

```js
function (params, sessionId) {}
```

Equivalent to the following but only for those events belonging to the given `session`:

```js
client.on('<domain>.<event>', callback);
```

#### Event: 'ready'

```js
function () {}
```

Emitted every time that there are no more pending commands waiting for a
response from the remote instance. The interaction is asynchronous so the only
way to serialize a sequence of commands is to use the callback provided by
the [`send`](#clientsendmethod-params-callback) method. This event acts as a
barrier and it is useful to avoid the *callback hell* in certain simple
situations.

Users are encouraged to extensively check the response of each method and should
prefer the promises API when dealing with complex asynchronous program flows.

For example to load a URL only after having enabled the notifications of both
`Network` and `Page` domains:

```js
client.Network.enable();
client.Page.enable();
client.once('ready', () => {
    client.Page.navigate({url: 'https://github.com'});
});
```

In this particular case, not enforcing this kind of serialization may cause that
the remote instance does not properly deliver the desired notifications the
client.


#### Event: 'disconnect'

```js
function () {}
```

Emitted when the instance closes the WebSocket connection.

This may happen for example when the user opens DevTools or when the tab is
closed.

#### client.send(method, [params], [sessionId], [callback])

Issue a command to the remote instance.

`method` is a string describing the command.

`params` is an object containing the payload.

`sessionId` is a string representing the session identifier.

`callback` is executed when the remote instance sends a response to this
command, it gets the following arguments:

- `error`: a boolean value indicating the success status, as reported by the
  remote instance;
- `response`: an object containing either the response (`result` field, if
  `error === false`) or the indication of the error (`error` field, if `error
  === true`).

When `callback` is omitted a `Promise` object is returned instead, with the
fulfilled/rejected states implemented according to the `error` parameter. The
`Error` object returned contains two additional parameters: `request` and
`response` which contain the raw massages, useful for debugging purposes. In
case of low-level WebSocket errors, the `error` parameter contains the
originating `Error` object and no `response` is returned.

Note that the field `id` mentioned in the [Chrome Debugging Protocol]
specification is managed internally and it is not exposed to the user.

For example:

```js
client.send('Page.navigate', {url: 'https://github.com'}, console.log);
```

#### client.`<domain>`.`<method>`([params], [sessionId], [callback])

Just a shorthand for:

```js
client.send('<domain>.<method>', params, sessionId, callback);
```

For example:

```js
client.Page.navigate({url: 'https://github.com'}, console.log);
```

#### client.`<domain>`.`<event>`([sessionId], [callback])

Just a shorthand for:

```js
client.on('<domain>.<event>[.<sessionId>]', callback);
```

When `callback` is omitted the event is registered only once and a `Promise`
object is returned. Notice though that in this case the optional `sessionId` usually passed to `callback` is not returned.

When `callback` is provided, it returns a function that can be used to
unsubscribe `callback` from the event, it can be useful when anonymous functions
are used as callbacks.

For example:

```js
const unsubscribe = client.Network.requestWillBeSent((params, sessionId) => {
    console.log(params.request.url);
});
unsubscribe();
```

#### client.close([callback])

Close the connection to the remote instance.

`callback` is executed when the WebSocket is successfully closed.

When `callback` is omitted a `Promise` object is returned.

#### client['`<domain>`.`<name>`']

Just a shorthand for:

```js
client.<domain>.<name>
```

Where `<name>` can be a command, an event, or a type.

## FAQ

### Invoking `Domain.methodOrEvent` I obtain `Domain.methodOrEvent is not a function`

This means that you are trying to use a method or an event that are not present
in the protocol descriptor that you are using.

If the protocol is fetched from Chrome directly, then it means that this version
of Chrome does not support that feature. The solution is to update it.

If you are using a local or custom version of the protocol, then it means that
the version is obsolete. The solution is to provide an up-to-date one, or if you
are using the protocol embedded in chrome-remote-interface, make sure to be
running the latest version of this module. In case the embedded protocol is
obsolete, please [file an issue](https://github.com/cyrus-and/chrome-remote-interface/issues/new).

See [here](#chrome-debugging-protocol-versions) for more information.

### Invoking `Domain.method` I obtain `Domain.method wasn't found`

This means that you are providing a custom or local protocol descriptor
(`CDP({protocol: customProtocol})`) which declares `Domain.method` while the
Chrome version that you are using does not support it.

To inspect the currently available protocol descriptor use:

```
$ chrome-remote-interface inspect
```

See [here](#chrome-debugging-protocol-versions) for more information.

### Why my program stalls or behave unexpectedly if I run Chrome in a Docker container?

This happens because the size of `/dev/shm` is set to 64MB by default in Docker
and may not be enough for Chrome to navigate certain web pages.

You can change this value by running your container with, say,
`--shm-size=256m`.

### Using `Runtime.evaluate` with `awaitPromise: true` I sometimes obtain `Error: Promise was collected`

This is thrown by `Runtime.evaluate` when the browser-side promise gets
*collected* by the Chrome's garbage collector, this happens when the whole
JavaScript execution environment is invalidated, e.g., a when page is navigated
or reloaded while a promise is still waiting to be resolved.

Here is an example:

```
$ chrome-remote-interface inspect
>>> Runtime.evaluate({expression: `new Promise(() => {})`, awaitPromise: true})
>>> Page.reload() // then wait several seconds
{ result: {} }
{ error: { code: -32000, message: 'Promise was collected' } }
```

To fix this, just make sure there are no pending promises before closing,
reloading, etc. a page.

### How does this compare to Puppeteer?

[Puppeteer] is an additional high-level API built upon the [Chrome Debugging
Protocol] which, among the other things, may start and use a bundled version of
Chromium instead of the one installed on your system. Use it if its API meets
your needs as it would probably be easier to work with.

chrome-remote-interface instead is just a general purpose 1:1 Node.js binding
for the [Chrome Debugging Protocol]. Use it if you need all the power of the raw
protocol, e.g., to implement your own high-level API.

See [#240] for a more thorough discussion.

[Puppeteer]: https://github.com/GoogleChrome/puppeteer
[#240]: https://github.com/cyrus-and/chrome-remote-interface/issues/240

## Contributors

- [Andrey Sidorov](https://github.com/sidorares)
- [Greg Cochard](https://github.com/gcochard)

## Resources

- [Chrome Debugging Protocol]
- [Chrome Debugging Protocol Google group](https://groups.google.com/forum/#!forum/chrome-debugging-protocol)
- [devtools-protocol official repo](https://github.com/ChromeDevTools/devtools-protocol)
- [Showcase Chrome Debugging Protocol Clients](https://developer.chrome.com/devtools/docs/debugging-clients)
- [Awesome chrome-devtools](https://github.com/ChromeDevTools/awesome-chrome-devtools)

[Chrome Debugging Protocol]: https://chromedevtools.github.io/devtools-protocol/
