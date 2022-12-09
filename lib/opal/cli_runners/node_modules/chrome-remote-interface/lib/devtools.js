'use strict';

const http = require('http');
const https = require('https');

const defaults = require('./defaults.js');
const externalRequest = require('./external-request.js');

// options.path must be specified; callback(err, data)
function devToolsInterface(path, options, callback) {
    const transport = options.secure ? https : http;
    const requestOptions = {
        host: options.host || defaults.HOST,
        port: options.port || defaults.PORT,
        useHostName: options.useHostName,
        path: (options.alterPath ? options.alterPath(path) : path)
    };
    externalRequest(transport, requestOptions, callback);
}

// wrapper that allows to return a promise if the callback is omitted, it works
// for DevTools methods
function promisesWrapper(func) {
    return (options, callback) => {
        // options is an optional argument
        if (typeof options === 'function') {
            callback = options;
            options = undefined;
        }
        options = options || {};
        // just call the function otherwise wrap a promise around its execution
        if (typeof callback === 'function') {
            func(options, callback);
            return undefined;
        } else {
            return new Promise((fulfill, reject) => {
                func(options, (err, result) => {
                    if (err) {
                        reject(err);
                    } else {
                        fulfill(result);
                    }
                });
            });
        }
    };
}

function Protocol(options, callback) {
    // if the local protocol is requested
    if (options.local) {
        const localDescriptor = require('./protocol.json');
        callback(null, localDescriptor);
        return;
    }
    // try to fetch the protocol remotely
    devToolsInterface('/json/protocol', options, (err, descriptor) => {
        if (err) {
            callback(err);
        } else {
            callback(null, JSON.parse(descriptor));
        }
    });
}

function List(options, callback) {
    devToolsInterface('/json/list', options, (err, tabs) => {
        if (err) {
            callback(err);
        } else {
            callback(null, JSON.parse(tabs));
        }
    });
}

function New(options, callback) {
    let path = '/json/new';
    if (Object.prototype.hasOwnProperty.call(options, 'url')) {
        path += `?${options.url}`;
    }
    devToolsInterface(path, options, (err, tab) => {
        if (err) {
            callback(err);
        } else {
            callback(null, JSON.parse(tab));
        }
    });
}

function Activate(options, callback) {
    devToolsInterface('/json/activate/' + options.id, options, (err) => {
        if (err) {
            callback(err);
        } else {
            callback(null);
        }
    });
}

function Close(options, callback) {
    devToolsInterface('/json/close/' + options.id, options, (err) => {
        if (err) {
            callback(err);
        } else {
            callback(null);
        }
    });
}

function Version(options, callback) {
    devToolsInterface('/json/version', options, (err, versionInfo) => {
        if (err) {
            callback(err);
        } else {
            callback(null, JSON.parse(versionInfo));
        }
    });
}

module.exports.Protocol = promisesWrapper(Protocol);
module.exports.List = promisesWrapper(List);
module.exports.New = promisesWrapper(New);
module.exports.Activate = promisesWrapper(Activate);
module.exports.Close = promisesWrapper(Close);
module.exports.Version = promisesWrapper(Version);
