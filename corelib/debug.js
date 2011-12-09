// debug funcall
VM.f = function(recv, jsid) {
  var args = ArraySlice.call(arguments, 2), body;

  if (recv == null) {
    rb_raise(RubyNoMethodError, 'tried sending method to null/undefined: `' + jsid + '`');
  }
  if (!(body = recv[jsid])) {
    rb_raise(RubyNoMethodError, 'undefined method `' + jsid + '` for: ' + recv.m$inspect());
  }
  return body.apply(recv, args);
}

var debug_stack = []

// debug funcall + stack traces
function debug_stack_trace_call(recv, jsid) {
  var args = ArraySlice.call(arguments, 2), body, result;

  if (recv == null) {
    rb_raise(RubyNoMethodError, 'tried sending method to null/undefined: `' + jsid + '`');
  }
  else if (!(body = recv[jsid])) {
    recv = recv.m$inspect ? recv.m$inspect() : recv.toString();
    rb_raise(RubyNoMethodError, 'undefined method `' + jsid_to_mid(jsid) + '`for: ' + recv);
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

VM.f = debug_stack_trace_call;

// Print error backtrace to console
VM.bt = function(err) {
  console.log(err.$k.__classid__ + ": " + err.message);
  var bt = rb_exc_backtrace(err);
  console.log("\t" + bt.join("\n\t"));
};

function rb_exc_backtrace(err) {
  var old = Error.prepareStackTrace;
  Error.prepareStackTrace = rb_prepare_backtrace;

  var backtrace = err.stack;
  Error.prepareStackTrace = old;

  if (backtrace && backtrace.join) {
    return backtrace;
  }

  return ["No backtrace available"];
}

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

function rb_prepare_backtrace(error, stack) {
  var code = [], f, b, k;

  for (var i = 0; i < stack.length; i++) {
    f = stack[i];
    b = f.getFunction();

    if (!(k = b.$rbKlass)) {
      continue;
    }

    code.push("from " + f.getFileName() + ":" + f.getLineNumber() + ":in `" + b.$rbName + "' on " + rb_inspect_object(k));
  }

  return code;
}

