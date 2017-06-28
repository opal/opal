'use strict';

// callback(err, data)
function externalRequest(transport, options, callback) {
    const request = transport.get(options, function (response) {
        let data = '';
        response.on('data', function (chunk) {
            data += chunk;
        });
        response.on('end', function () {
            if (response.statusCode === 200) {
                callback(null, data);
            } else {
                callback(new Error(data));
            }
        });
    });
    request.on('error', function (err) {
        callback(err);
    });
}

module.exports = externalRequest;
