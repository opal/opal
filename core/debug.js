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
