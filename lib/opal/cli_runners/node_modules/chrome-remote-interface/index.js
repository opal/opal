'use strict';

const EventEmitter = require('events');
const dns = require('dns');

const devtools = require('./lib/devtools.js');
const Chrome = require('./lib/chrome.js');

// XXX reset the default that has been changed in
// (https://github.com/nodejs/node/pull/39987) to prefer IPv4. since
// implementations alway bind on 127.0.0.1 this solution should be fairly safe
// (see #467)
if (dns.setDefaultResultOrder) {
    dns.setDefaultResultOrder('ipv4first');
}

function CDP(options, callback) {
    if (typeof options === 'function') {
        callback = options;
        options = undefined;
    }
    const notifier = new EventEmitter();
    if (typeof callback === 'function') {
        // allow to register the error callback later
        process.nextTick(() => {
            new Chrome(options, notifier);
        });
        return notifier.once('connect', callback);
    } else {
        return new Promise((fulfill, reject) => {
            notifier.once('connect', fulfill);
            notifier.once('error', reject);
            new Chrome(options, notifier);
        });
    }
}

module.exports = CDP;
module.exports.Protocol = devtools.Protocol;
module.exports.List = devtools.List;
module.exports.New = devtools.New;
module.exports.Activate = devtools.Activate;
module.exports.Close = devtools.Close;
module.exports.Version = devtools.Version;
