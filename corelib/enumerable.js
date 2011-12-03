var RubyEnumerable;

function enum_all() {
  var result = true, iterator = enum_all.proc, func, proc;

  if (iterator) {
    var context = iterator.$S, val;
    enum_all.proc = 0;

    proc = function(e) {
      if ((val = iterator.call(context, e)) === breaker) return breaker.$v;
      if (val === false || val === nil) {
        result = false;
        breaker.$v = nil;
        return breaker;
      }
    };
  }
  else {
    proc = function(e) {
      if (e === false || e === nil) {
        result = false;
        breaker.$v = nil;
        return breaker;
      }
    };
  }

  func = this.m$each;
  func.proc = proc;
  func.call(this);

  return result;
}

function enum_any() {
  var result = false, iterator = enum_any.proc, func, proc;

  if (iterator) {
    var context = iterator.$S, val;
    enum_any.proc = 0;

    proc = function(e) {
      if ((val = iterator.call(context, e)) === breaker) return breaker.$v;
      if (val !== false && val !== nil) {
        result = true;
        breaker.$v = nil;
        return breaker;
      }
    };
  }
  else {
    proc = function(e) {
      if (e !== false && e !== nil) {
        result = true;
        breaker.$v = nil;
        return breaker;
      }
    };
  }

  func = this.m$each;
  func.proc = proc;
  func.call(this);

  return result;
}

function enum_collect() {
  var self = this, iterator = enum_collect.proc;
  if (!iterator) return self.m$enum_for("collect");

  var context = iterator.$S, result = [], val, e;
  enum_collect.proc = 0;

  var proc = function() {
    e = ArraySlice.call(arguments);
    if ((val = iterator.apply(context, e)) === breaker) return breaker.$v;
    result.push(val);
  };

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return result;
}

function enum_count(object) {
  var self = this, iterator = enum_count.proc, result = 0, val;

  if (iterator) {
    var context = iterator.$S;
    enum_count.proc = 0;
  }
  else if (object === undefined) {
    iterator = function() { return true; };
  }
  else {
    iterator = function(e) { return e.m$eq$(object); };
  }

  var proc = function(obj) {
    if ((val = iterator.call(context, obj)) === breaker) return breaker.$v;
    if (val !== false && val !== nil) result++;
  };

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return result;
}

function enum_detect(ifnone) {
  var self = this, iterator = enum_detect.proc;
  if (!iterator) return self.m$enum_for("detect");

  var result = nil, context = iterator.$S, val;
  enum_detect.proc = 0;

  var proc = function(e) {
    if ((val = iterator.call(context, e)) === breaker) return breaker.$v;
    if (val !== false && val !== nil) {
      result = e;
      breaker.$v = nil
      return breaker;
    }
  };

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  if (result !== nil) return result;
  if (typeof ifnone === 'function') return ifnone.m$call();
  return ifnone === undefined ? nil : ifnone;
}

function enum_drop(number) {
  var self = this, result = [], current = 0;
  var proc = function(e) {
    if (number < current) result.push(e);
    current++;
  };

  return result;
}

function enum_drop_while() {
  var self = this, iterator = enum_drop_while.proc;
  if (!iterator) return self.m$enum_for("drop_while");

  var result = [], context = iterator.$S, val;
  enum_drop_while.proc = 0;

  var proc = function(e) {
    if ((val = iterator.call(context, e)) === breaker) return breaker.$v;
    if (val !== false && val !== nil) result.push(e);
    else return breaker;
  };

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return result;
}

function enum_each_with_index() {
  var self = this, iterator = enum_each_with_index.proc;
  if (!iterator) return self.m$enum_for("each_with_index");

  var index = 0, context = iterator.$S, val;

  var proc = function(e) {
    if ((val = iterator.call(context, e, index)) === breaker) return breaker.$v;
    index++;
  };

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return nil;
}

function enum_entries() {
  var self = this, result = [];
  var proc = function(e) { return result.push(e); };
  var func = self.m$each;
  func.proc = proc;
  func.call(self);
  return result;
}

function enum_find_index(object) {
  var self = this, iterator = enum_find_index.proc, val, result = nil;
  if (object === undefined && !iterator) return self.$enum_for("find_index");

  if (object !== undefined) iterator = function(e) { return e.m$eq$(object); };
  else var context = iterator.$S;

  enum_find_index.proc = 0;

  var proc = function(obj, index) {
    if ((val = iterator.call(context, obj)) === breaker) return breaker.$v;
    if (val !== false && val !==nil) {
      result = obj;
      breaker.$v = index;
      return breaker;
    }
  };

  var func = self.m$each_with_index;
  func.proc = proc;
  func.call(self);

  return result;
}

function enum_first(number) {
  var result = [], proc;

  if (number === undefined) {
    proc = function(e) {
      result = e;
      return breaker;
    };
  }
  else {
    var current = 0;
    proc = function(e) {
      if (number < current) return breaker;
      result.push(e);
      current++;
    };
  }

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return result;
}

function enum_grep(pattern) {
  var self = this, ary = [], iterator = enum_grep.proc;

  if (iterator) {
    var context = iterator.$S, val;
    enum_grep.proc = 0;

    var proc = function(e) {
      if (val = pattern.m$eqq$(e), val !== false && val !== nil) {
        if ((val === iterator.call(context, e)) === breaker) return breaker.$v;
        ary.push(e);
      }
    };
  }
  else {
    var proc = function(e) {
      if (val === pattern.m$eqq$(e), val !== false && val !== nil) {
        ary.push(e);
      }
    };
  }

  var func = self.m$each;
  func.proc = proc;
  func.call(self);

  return ary;
}

function init_enumerable() {
  RubyEnumerable = define_module(rb_cObject, 'Enumerable');
  define_method(RubyEnumerable, 'm$all$p', enum_all);
  define_method(RubyEnumerable, 'm$any$p', enum_any);
  define_method(RubyEnumerable, 'm$collect', enum_collect);
  define_method(RubyEnumerable, 'm$count', enum_count);
  define_method(RubyEnumerable, 'm$detect', enum_detect);
  define_method(RubyEnumerable, 'm$find', enum_detect);
  define_method(RubyEnumerable, 'm$drop', enum_drop);
  define_method(RubyEnumerable, 'm$drop_while', enum_drop_while);
  define_method(RubyEnumerable, 'm$each_with_index', enum_each_with_index);
  define_method(RubyEnumerable, 'm$entries', enum_entries);
  define_method(RubyEnumerable, 'm$find_index', enum_find_index);
  define_method(RubyEnumerable, 'm$first', enum_first);
  define_method(RubyEnumerable, 'm$grep', enum_grep);

  define_method(RubyEnumerable, 'm$to_a', enum_entries);
}
