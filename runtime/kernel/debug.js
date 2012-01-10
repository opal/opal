// ..........................................................
// DEBUG - this is only included in debug mode
//

// An array of every method send in debug mode
var debug_stack = [];

opal.send = function(file, line, recv, block, jsid) {
  var args    = $slice.call(arguments, 5),
      meth    = recv[jsid],
      result;

  if (!meth) {
    throw new Error('need to call method_missing in opal.send for ' + jsid);
  }

  // Always set a block. If a block wasn't given then this is just a
  // no-op.
  meth.$P = block;

  // Push this call frame onto debug stack
  debug_stack.push({
    file: file,
    line: line,
    recv: recv,
    jsid: jsid,
    args: args,
    meth: meth
  });

  try {
    result = meth.apply(recv, args);
  }
  catch (err) {
    err.opal_stack = (err.opal_stack || []).concat(debug_stack);
    debug_stack    = [];

    throw err;
  }

  debug_stack.pop();

  return result;
};
