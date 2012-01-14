// ..........................................................
// DEBUG - this is only included in debug mode
//

// Identify opal as being in debug mode
opal.debug = true;

// An array of every method send in debug mode
var debug_stack = [];

opal.send = function(recv, block, jsid) {
  var args    = $slice.call(arguments, 3),
      meth    = recv[jsid],
      result;

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
    args: args,
    meth: meth
  });

  try {
    result = meth.apply(recv, args);
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

function get_debug_backtrace(err) {
  var result = [],
      stack  = err.opal_stack || [],
      frame,
      recv,
      meth;

  for (var i = stack.length - 1; i >= 0; i--) {
    frame = stack[i];
    meth  = frame.meth;
    recv  = frame.recv;
    klass = meth.$debugKlass;

    if (recv.$flags & T_OBJECT) {
      recv = class_real(recv.$klass);
      recv = (recv === klass ? recv.$name : klass.$name + '(' + recv.$name + ')') + '#';
    }
    else {

      recv = recv.$name + '.';
    }

    result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + meth.$debugFile + ':' + meth.$debugLine);
  }

  return result;
}

var release_define_method = define_method;

define_method = opal.defn = function(klass, id, body, file, line) {

  if (!body.$debugFile) {
    body.$debugFile  = file;
    body.$debugLine  = line;
    body.$debugKlass = klass;
  }

  return release_define_method(klass, id, body);
};
