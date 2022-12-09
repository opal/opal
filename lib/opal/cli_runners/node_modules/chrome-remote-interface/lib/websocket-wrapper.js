'use strict';

const EventEmitter = require('events');

// wrapper around the Node.js ws module
// for use in browsers
class WebSocketWrapper extends EventEmitter {
    constructor(url) {
        super();
        this._ws = new WebSocket(url); // eslint-disable-line no-undef
        this._ws.onopen = () => {
            this.emit('open');
        };
        this._ws.onclose = () => {
            this.emit('close');
        };
        this._ws.onmessage = (event) => {
            this.emit('message', event.data);
        };
        this._ws.onerror = () => {
            this.emit('error', new Error('WebSocket error'));
        };
    }

    close() {
        this._ws.close();
    }

    send(data, callback) {
        try {
            this._ws.send(data);
            callback();
        } catch (err) {
            callback(err);
        }
    }
}

module.exports = WebSocketWrapper;
