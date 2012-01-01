function exc_backtrace(err) {
  var old = Error.prepareStackTrace;
  Error.prepareStackTrace = prepare_backtrace;

  var backtrace = err.stack;
  Error.prepareStackTrace = old;

  if (backtrace && backtrace.join) {
    return backtrace;
  }

  return ["No backtrace available"];
}

function prepare_backtrace(error, stack) {
  var code = [], f, b, k, name, self;

  for (var i = 0; i < stack.length; i++) {
    f = stack[i];
    b = f.getFunction();
    name = f.getMethodName();
    self = f.getThis();
    
    if (!self.$klass || !name) {
      continue;
    }
    
    self  = (self.$flags & T_OBJECT ?
           class_real(self.$klass).__classid__ + '#' :
           self.__classid__ + '.');

    code.push("from " + self + jsid_to_mid(name) + ' at ' + f.getFileName() + ":" + f.getLineNumber());
  }

  return code;
}

// Print error backtrace to console
opal.backtrace = opal.bt = function(err) {
  console.log(err.$klass.__classid__ + ": " + err.message);
  console.log("\t" + exc_backtrace(err).join("\n\t"));
};
