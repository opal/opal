var RubyException,        RubyStandardError,      RubyRuntimeError,
    RubyLocalJumpError,   RubyTypeError,          RubyNameError,
    RubyNoMethodError,    RubyArgError,           RubyScriptError,
    RubyLoadError,        RubyIndexError,         RubyKeyError,
    RubyRangeError,       RubyNotImplError;

var breaker;

// Raise a new exception using exception class and message
function rb_raise(exc, str) {
  throw exc.m$new(str);
}

// Inspect object or class
function rb_inspect_object(obj) {
  if (obj.$f & T_OBJECT) {
    return "#<" + rb_class_real(obj.$k).__classid__ + ":0x" + (obj.$id * 400487).toString(16) + ">";
  }
  else {
    return obj.__classid__;
  }
}

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

function exc_initialize(message) {
  if (Error.captureStackTrace) Error.captureStackTrace(this);
  return this.message = message || '';
}

function exc_backtrace() {
  if (!this._bt) this._bt = rb_exc_backtrace(this);
  return this._bt;
}

function exc_inspect() {
  return '#<' + this.$k.m$to_s() + ': \'' + this.message + '\'>';
}

function exc_message() {
  return this.message;
}

function init_error() {
  RubyException     = rb_bridge_class(Error, T_OBJECT, 'Exception');

  define_bridge_methods(RubyException, {
    'm$initialize': exc_initialize,
    'm$backtrace': exc_backtrace,
    'm$inspect': exc_inspect,
    'm$message': exc_message,
    'm$to_s': exc_message
  });

  RubyStandardError = define_class(rb_cObject, 'StandardError', RubyException);
  RubyRuntimeError  = define_class(rb_cObject, 'RuntimeError', RubyException);
  RubyLocalJumpError= define_class(rb_cObject, 'LocalJumpError', RubyStandardError);
  RubyTypeError     = define_class(rb_cObject, 'TypeError', RubyStandardError);
  RubyNameError     = define_class(rb_cObject, 'NameError', RubyStandardError);
  RubyNoMethodError = define_class(rb_cObject, 'NoMethodError', RubyNameError);
  RubyArgError      = define_class(rb_cObject, 'ArgumentError', RubyStandardError);
  RubyScriptError   = define_class(rb_cObject, 'ScriptError', RubyException);
  RubyLoadError     = define_class(rb_cObject, 'LoadError', RubyScriptError);
  RubyIndexError    = define_class(rb_cObject, 'IndexError', RubyStandardError);
  RubyKeyError      = define_class(rb_cObject, 'KeyError', RubyIndexError);
  RubyRangeError    = define_class(rb_cObject, 'RangeError', RubyStandardError);
  RubyNotImplError  = define_class(rb_cObject, 'NotImplementedError', RubyException);

  RubyBreakInstance = new Error('unexpected break');
  RubyBreakInstance.$k = RubyLocalJumpError;
  RubyBreakInstance.$t = function() { throw this; };
  VM.B = RubyBreakInstance;
  breaker = RubyBreakInstance;
}
