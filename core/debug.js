// ..........................................................
// DEBUG - this is only included in debug mode
//

// Identify opal as being in debug mode
opal.debug = true;

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

function get_debug_backtrace(err) {
  var result = [],
      stack  = err.opal_stack || [],
      frame,
      recv;

  for (var i = stack.length - 1; i >= 0; i--) {
    frame = stack[i];
    recv  = frame.recv;
    recv  = (recv.$flags & T_OBJECT ?
      class_real(recv.$klass).$name + '#' :
      recv.$name + '.');

    result.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + frame.file + ':' + frame.line);
  }

  return result;
}
