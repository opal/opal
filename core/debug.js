// ..........................................................
// DEBUG - this is only included in debug mode
//

// Identify opal as being in debug mode
opal.debug = true;

// An array of every method send in debug mode
var debug_stack = [];

opal.send = function(recv, block, jsid) {
  var args    = $slice.call(arguments, 3),
      meth    = recv[jsid];

  if (!meth) {
    args.unshift(jsid_to_mid(jsid));
    return recv.$method_missing.apply(recv, args);
  }

  // Always set a block. If a block wasn't given then this is just a
  // no-op.
  meth.$P = block;

  // Push this call frame onto debug stack
  debug_stack.push({
    recv: recv,
    jsid: jsid,
    meth: meth
  });

  try {
    var result = meth.apply(recv, args);
  }
  catch (err) {
    if (!err.opal_stack) {
      err.opal_stack = debug_stack.slice();
    }

    throw err;
  }
  finally {
    debug_stack.pop();
  }

  return result;
};

var release_define_method = define_method;

define_method = opal.defn = function(klass, id, body, file, line) {

  if (!body.$debugFile) {
    body.$debugFile  = file;
    body.$debugLine  = line;
    body.$debugKlass = klass;
  }

  return release_define_method(klass, id, body);
};

var release_main = opal.main;

opal.main = function(id) {

  if (false) {
    release_main(id);
  }
  else {
    try {
      release_main(id);
    }
    catch (e) {
      var str = e.o$klass.o$name + ': ' + e.message;
      str += "\n\t" + e.$backtrace().join("\n\t");
      console.error(str);
    }
  }
};

function debug_get_backtrace(err) {
  if (true) {
    var old = Error.prepareStackTrace;
    Error.prepareStackTrace = debug_chrome_build_stacktrace;
    var stack = err.stack || [];

    Error.prepareStackTrace = old;
    return stack;
  }

  return ['No backtrace available'];
}

function debug_chrome_stacktrace(err, stack) {
  return debug_chrome_build_stacktrace(err, stack).join('');
}

function debug_chrome_build_stacktrace(err, stack) {
  var code = [], f, b, k, name, recv, str, klass;

  for (var i = 0; i < stack.length; i++) {
    continue;
    f = stack[i];
    b = f.getFunction();
    name = f.getMethodName();
    recv = f.getThis();
    str  = ""

    if (!recv.o$klass || !name) {
      str = f.getFunctionName();
    }
    else {
      klass = b.$debugKlass;
      if (klass && recv.o$flags & T_OBJECT) {
        recv = class_real(recv.o$klass);
        recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
      }
      else {

        recv = recv.o$name + '.';
      }

      //code.push("from " + self + jsid_to_mid(name) + ' at ' + f.getFileName() + ":" + f.getLineNumber());
      str = recv + jsid_to_mid(name) + ' at ' + b.$debugFile + ":" + b.$debugLine;
    }

    code.push("from " + str + " (" + f.getFileName() + ":" + f.getLineNumber() + ")");
  }

  return code;
  //var result = [],
      //frame,
      //recv,
      //meth;

  //for (var i = stack.length - 1; i >= 0; i--) {
    //frame = stack[i];
    //meth  = frame.meth;
    //recv  = frame.recv;
    //klass = meth.$debugKlass;

    //if (recv.o$flags & T_OBJECT) {
      //recv = class_real(recv.o$klass);
      //recv = (recv === klass ? recv.o$name : klass.o$name + '(' + recv.o$name + ')') + '#';
    //}
    //else {

      //recv = recv.o$name + '.';
    //}

    //result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + meth.$debugFile + ':' + meth.$debugLine);
  //}

  //return result;
}
