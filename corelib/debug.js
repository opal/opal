var debug_stack = []

// debug funcall + stack traces
function debug_funcall(recv, jsid) {
  var args = ArraySlice.call(arguments, 2), body, result;

  if (recv == null || !(body = recv[jsid])) {
    var mid = jsid_to_mid(jsid), msg = "undefined method `" + mid;

    if (recv == null)
      msg += "' on null (native null).";
    else if (!recv.$k)
      msg += "' on native object (" + recv.toString() + ").";
    else if (recv === nil)
      msg += "' on nil:NilClass.";
    else if (recv.$f & T_OBJECT)
      msg += "' on an instance of " + rb_class_real(recv.$k).__classid__ + ".";
    else
      msg += "' on " + recv.__classid__ + ".";

    rb_raise(RubyNoMethodError, msg);
  }

  debug_stack.push({
    recv: recv,
    jsid: jsid,
    args: args,
    body: body
  });

  try {
    result = body.apply(recv, args);
  }
  catch (err) {
    err.opal_stack = (err.opal_stack || []).concat(debug_stack);
    debug_stack = [];
    throw err;
  }
  debug_stack.pop();
  return result;
}

VM.f = debug_funcall;

// Print error backtrace to console
VM.bt = function(err) {
  console.log(err.$k.__classid__ + ": " + err.message);
  var bt = rb_exc_backtrace(err);
  console.log("\t" + bt.join("\n\t"));
};

function rb_exc_backtrace(err) {
  var stack = [], debug_stack = err.opal_stack || [], frame, recv, body;
  for (var i = debug_stack.length - 1; i >= 0; i--) {
    frame = debug_stack[i];
    recv = frame.recv;
    body = frame.body;
    recv = (recv.$f & T_OBJECT ? rb_class_real(recv.$k).__classid__ + '#' : recv.__classid__ + '.');
    stack.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + body.$rbFile + ':' + body.$rbLine);
  }
  return stack;
}
