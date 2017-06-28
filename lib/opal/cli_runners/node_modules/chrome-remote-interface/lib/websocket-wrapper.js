const EventEmitter = require('events');

// wrapper around the Node.js ws module
// for use in browsers
class WebSocketWrapper extends EventEmitter {
    constructor(url) {
        super();
        this._ws = new WebSocket(url);
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

    send(data) {
        this._ws.send(data);
    }
}

module.exports = WebSocketWrapper;
