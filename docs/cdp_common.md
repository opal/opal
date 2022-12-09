### Common CDP of Chrome, Firefox, Node and Deno

cdp_common.json documents a subset of the common CDP as reported by Chrome, version 107 and Firefox, version 106.
All entries that where marked as "experimental" or "deprecated" have been removed.
Only entries, that where included in both browsers with equal state have been kept.

The CDP as implemented by Chrome or Firefox can be retrieved directly from the browsers by starting them with the `--remote-debugging-port` option
and visiting the (http://localhost:9222/json/protocol)[http://localhost:9222/json/protocol] endpoint.

Unfortunately, Firefox advertising this protocol support doesn't mean it actually is available or even works!
Various domains and methods, advertised as available from Firefox, present a "UnknownMethodError" or other errors.

The Node and Deno CDP protocol can be inspected by starting them with the `--inspect` option and visiting the
(http://localhost:9229/json/protocol)[http://localhost:9229/json/protocol] endpoint.

The actual websocket endpoint uri can be retrieved at (http://localhost:9222/json/version)[http://localhost:9222/json/version]
or as list of targets at (http://localhost:9222/json/list)[http://localhost:9222/json/list],
likewise in Node or Deno with the adjusted port number.
