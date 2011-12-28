var debug_stack = []

// debug funcall + stack traces
function debug_funcall(file, line, recv, jsid) {
  var args = $slice.call(arguments, 4), body, result;

  if (recv == null || !(body = recv[jsid])) {
    var mid = jsid_to_mid(jsid), msg = "undefined method `" + mid;

    if (recv == null) {
      msg += "' on null (native null).";
    }
    else if (!recv.$klass) {
      msg += "' on native object (" + recv.toString() + ").";
    }
    else if (recv === nil) {
      msg += "' on nil:NilClass.";
    }
    else if (recv.$flags & T_OBJECT) {
      msg += "' on an instance of " + class_real(recv.$klass).__classid__ + ".";
    }
    else {
      msg += "' on " + recv.__classid__ + ".";
    }

    raise(RubyNoMethodError, msg);
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

opal.send = debug_funcall;

function exc_backtrace(err) {
  var stack       = [],
      debug_stack = err.opal_stack || [],
      frame,
      recv;

  for (var i = debug_stack.length - 1; i >= 0; i--) {
    frame = debug_stack[i];
    recv  = frame.recv;
    recv  = (recv.$flags & T_OBJECT ?
      class_real(recv.$klass).__classid__ + '#' :
      recv.__classid__ + '.');

    stack.push('from ' + recv + jsid_to_mid(frame.jsid) + ' at ' + frame.file + ':' + frame.line);
  }

  return stack;
}

// Print error backtrace to console
opal.backtrace = opal.bt = function(err) {
  console.log(err.$klass.__classid__ + ": " + err.message);
  console.log("\t" + exc_backtrace(err).join("\n\t"));
};
