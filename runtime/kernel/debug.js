var debug_stack = []

// debug funcall + stack traces
function debug_funcall(file, line, recv, jsid) {
  var args = ArraySlice.call(arguments, 4), body, result;

  if (recv == null || !(body = recv[jsid])) {
    var mid = jsid_to_mid(jsid), msg = "undefined method `" + mid;

    if (recv == null) {
      msg += "' on null (native null).";
    }
    else if (!recv.$k) {
      msg += "' on native object (" + recv.toString() + ").";
    }
    else if (recv === nil) {
      msg += "' on nil:NilClass.";
    }
    else if (recv.$f & T_OBJECT) {
      msg += "' on an instance of " + rb_class_real(recv.$k).__classid__ + ".";
    }
    else {
      msg += "' on " + recv.__classid__ + ".";
    }

    rb_raise(RubyNoMethodError, msg);
  }

  debug_stack.push({
    file: file,
    line: line,
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
    debug_stack    = [];

    throw err;
  }

  debug_stack.pop();

  return result;
}

opal.call = opal.f = debug_funcall;

function rb_exc_backtrace(err) {
  var stack       = [],
      debug_stack = err.opal_stack || [],
      frame,
      recv;

  for (var i = debug_stack.length - 1; i >= 0; i--) {
    frame = debug_stack[i];
    recv  = frame.recv;
    recv  = (recv.$f & T_OBJECT ?
      rb_class_real(recv.$k).__classid__ + '#' :
      recv.__classid__ + '.');

    stack.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + frame.file + ':' + frame.line);
  }

  return stack;
}

// Print error backtrace to console
opal.backtrace = opal.bt = function(err) {
  console.log(err.$k.__classid__ + ": " + err.message);
  console.log("\t" + rb_exc_backtrace(err).join("\n\t"));
};
