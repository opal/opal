// line_reader.js
// NullPointer's Blog
// http://paulownia.hatenablog.com/entry/2012/09/29/024439

var util = require("util");
var events = require("events");

function LineReader(stream) {
	var self = this;
	this.buf = "";
	this.rs = stream || process.stdin;
	this.rs.on("data", function(chunk) { self._onStreamData(chunk) });
	this.rs.on("end", function() { self._onStreamEnd() });
	this.rs.on("close", function() { self._onStreamClose() });
	this.rs.setEncoding("utf8");
}
util.inherits(LineReader, events.EventEmitter);

LineReader.prototype.read = function() {
	this.rs.resume();
};

LineReader.prototype.destroy = function() {
	this.buf = "";
	this.rs.destroy();
};

LineReader.prototype._onStreamEnd = function() {
	if (this.buf) {
		this.emit('line', this.buf);
	}
	this.emit('end');
};

LineReader.prototype._onStreamClose = function() {
	this.emit('close');
};

LineReader.prototype._onStreamData = function(chunk) {

	this.rs.pause();
	this.buf += chunk;

	var self = this;
	(function searchLine() {

		var i = self.buf.indexOf('\n');
		if (i >= 0) {
			var line = self.buf.slice(0, i + 1);
			self.buf = self.buf.slice(i + 1);
			self.emit('line', line);
			// setImmediate( searchLine );
			searchLine();
		} else {
			self.rs.resume();
		}
	})();
};

exports.LineReader = LineReader;
