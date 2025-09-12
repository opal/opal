# Common CDP of Chrome, Firefox and Node

The CDP as implemented by Chrome or Firefox can be retrieved directly from the browsers by starting them with the `--remote-debugging-port` option
and visiting the (http://localhost:9222/json/protocol)[http://localhost:9222/json/protocol] endpoint.

The Node CDP protocol can be inspected by starting them with the `--inspect` option and visiting the
(http://localhost:9229/json/protocol)[http://localhost:9229/json/protocol] endpoint.

The actual websocket endpoint uri can be retrieved at (http://localhost:9222/json/version)[http://localhost:9222/json/version]
or as list of targets at (http://localhost:9222/json/list)[http://localhost:9222/json/list],
likewise in Node with the adjusted port number.
