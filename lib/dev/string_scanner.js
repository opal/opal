var StringScanner = function(str) {
    this._str = str;
    this._at = 0;
    this.matched = "";
    return this._workingString = str;
};

StringScanner.prototype.scan = function(reg) {
    var res;
    res = reg.exec(this._workingString);
    if (res === null) {
        this.matched = "";
        return false;
    } else if (typeof res === "object") {
        this._at += res[0].length;
        this._workingString = this._workingString.substr(res[0].length);
        this.matched = res[0];
        return res;
    } else if (typeof res === "string") {
        this._at += res.length;
        this._workingString = this._workingString.substr(res.length);
        return res;
    } else {
        return false;
    };
};

StringScanner.prototype.check = function(reg) {
    return reg.exec(this._workingString);
};
StringScanner.prototype.peek = function(len) {
    return this._workingString.substr(0, len);
};

StringScanner.prototype.eos = function() {
  return this._workingString.length == 0;
};

opal.dev.StringScanner = StringScanner;

