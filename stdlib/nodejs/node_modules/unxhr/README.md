> Synchronous and asynchronous XMLHttpRequest for Node

[![Build Status: Linux](https://travis-ci.org/Mogztter/unxhr.svg?branch=master)](https://travis-ci.org/Mogztter/unxhr) [![install size](https://packagephobia.now.sh/badge?p=unxhr)](https://packagephobia.now.sh/result?p=unxhr)

_unxhr_ is a tiny wrapper of the built-in `http` client to emulate the browser `XMLHttpRequest` object.

**Important:** This library is a fork of [XMLHttpRequest](https://github.com/driverdan/node-XMLHttpRequest).
It was created to be compliant with [XMLHttpRequest Level 2](http://www.w3.org/TR/XMLHttpRequest2/).

## Highlights

- Dependency free
- Asynchronous and synchronous requests
- `GET`, `POST`, `PUT`, and `DELETE` requests
- Binary data using JavaScript typed arrays
- Follows redirects
- Handles `file://` protocol

## Usage

Here's how to include the module in your project and use as the browser-based XHR object.

```js
const XMLHttpRequest = require('unxhr').XMLHttpRequest
const xhr = new XMLHttpRequest()
```

## Known Issues / Missing Features

For a list of open issues or to report your own visit the [github issues page](https://github.com/Mogztter/unxhr/issues).

* Local file access may have unexpected results for non-UTF8 files
* Synchronous requests don't set headers properly
* Synchronous requests freeze node while waiting for response (But that's what you want, right? Stick with async!).
* Some events are missing, such as abort
* Cookies aren't persisted between requests
* Missing XML support

## License

MIT license. See LICENSE for full details.
