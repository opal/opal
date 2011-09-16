class StringScanner

  def initialize(str)
    `self._str = str;
     self._at = 0;
     self._matched = "";
     self._working_string = str;`
     nil
  end

  def scan(reg)
    `reg = new RegExp('^' + reg.toString().substr(1, reg.toString().length - 2));
    var res = reg.exec(self._working_string);

    if (res == null) {
      self.matched = "";
      return false;
    }
    else if (typeof res == 'object') {
      self._at += res[0].length;
      self._working_string = self._working_string.substr(res[0].length);
      self._matched = res[0];
      return res[0];
    }
    else if (typeof res == 'string') {
      self._at += res.length;
      self._working_string = self._working_string.substr(res.length);
      return res;
    }
    else {
      return false;
    }`
  end

  def check(reg)
    `reg = new RegExp('^' + reg.toString().substr(1, reg.toString().length - 2));
    return reg.exec(self._working_string) ? true : false;`
  end

  def peek(len)
    `return self._working_string.substr(0, len);`
  end

  def eos?
    `return self._working_string.length == 0;`
  end

  def matched
    `return self._matched;`
  end
end

