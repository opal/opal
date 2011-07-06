// ..........................................................
// Debug Mode
//

var Db = {};

function init_debug() {
  // replace define method with our wrapped version
  var old_dm = Rt.dm;

  Rt.dm = function(klass, name, public_body, arity) {
    var debug_body = function() {
      var res, len = arguments.length, arity = debug_body.$rbArity;

      if (arity >= 0) {
        if (arity != len - 1) {
          raise(eArgError, "wrong number of arguments(" + (len - 1) + " for " + arity + ")");
        }
      }
      else {
        if ((-arity - 1) > len) {
          console.log("raising for " + name + " " + len + " for " + arity);
          raise(eArgError, "wrong number of arguments(" + len + " for " + arity + ")");
        }
      }

      // push call onto stack
      Db.push(klass, arguments[0], name, Array.prototype.slice.call(arguments, 1));

      // check for block and pass it on
      if (block.f == arguments.callee) {
        block.f = public_body
      }

      res = public_body.apply(this, [].slice.call(arguments));

      Db.pop();

      return res;
    };

    public_body.$rbWrap = debug_body;

    return old_dm(klass, name, debug_body, arity);
  };

  // replace super handler with wrapped version
  var old_super = Rt.S;

  Rt.S = function(callee, self, args) {
    return old_super(callee.$rbWrap, self, args);
  };

  // stack trace - chrome/v8/gem/node support
  if (Error.prepareStackTrace) {

  }
  else {

  }
};


Db.stack = [];

Db.push = function(klass, object, method) {
  this.stack.push({ klass: klass, object: object, method: method });
};

Db.pop = function() {
  this.stack.pop();
};

// Returns string
Db.backtrace = function() {
  var trace = [], stack = this.stack, frame;

  for (var i = stack.length - 1; i >= 0; i--) {
    frame = stack[i];
    trace.push("\tfrom " + frame.klass.$m.inspect(frame.klass) + '#' + frame.method);
  }

  return trace.join("\n");
};
