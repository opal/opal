// Initialization
// --------------

// The *instances* of core objects
var boot_Object = boot_defclass();
var boot_Module = boot_defclass(boot_Object);
var boot_Class  = boot_defclass(boot_Module);

// The *classes' of core objects
var rb_cObject = boot_makemeta('Object', boot_Object, boot_Class);
var rb_cModule = boot_makemeta('Module', boot_Module, rb_cObject.constructor);
var rb_cClass = boot_makemeta('Class', boot_Class, rb_cModule.constructor);

// Fix boot classes to use meta class
rb_cObject.$k = rb_cClass;
rb_cModule.$k = rb_cClass;
rb_cClass.$k = rb_cClass;

// fix superclasses
rb_cObject.$s = null;
rb_cModule.$s = rb_cObject;
rb_cClass.$s = rb_cModule;

rb_cObject.$c.BasicObject = rb_cObject;
rb_cObject.$c.Object = rb_cObject;
rb_cObject.$c.Module = rb_cModule;
rb_cObject.$c.Class = rb_cClass;

VM.Object = rb_cObject;

// core, non-bridged, classes
var rb_cMatch     = define_class(rb_cObject, 'MatchData', rb_cObject);
var rb_cRange     = define_class(rb_cObject, 'Range', rb_cObject);
var rb_cNilClass  = define_class(rb_cObject, 'NilClass', rb_cObject);

var rb_top_self = VM.top = new rb_cObject.$a();

var RubyNilClass = define_class(rb_cObject, 'NilClass', rb_cObject);
var nil = VM.nil = new RubyNilClass.$a();

// core bridged classes
var RubyArray = rb_bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');
var RubyHash = define_class(rb_cObject, 'Hash', rb_cObject);

var RubyNumeric = rb_bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');
var RubyInteger = define_class(rb_cObject, 'Integer', RubyNumeric);
var RubyFloat = define_class(rb_cObject, 'Float', RubyNumeric);

var RubyString = rb_bridge_class(String, T_OBJECT | T_STRING, 'String');
var RubyBoolean     = rb_bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
var RubyTrueClass   = define_class(rb_cObject, 'TrueClass', rb_cObject);
var RubyFalseClass  = define_class(rb_cObject, 'FalseClass', rb_cObject);
var rb_cProc      = rb_bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
var rb_cRegexp    = rb_bridge_class(RegExp, T_OBJECT, 'Regexp');

var RubyException     = rb_bridge_class(Error, T_OBJECT, 'Exception');

var RubyStandardError = define_class(rb_cObject, 'StandardError', RubyException);
var RubyRuntimeError  = define_class(rb_cObject, 'RuntimeError', RubyException);
var RubyLocalJumpError= define_class(rb_cObject, 'LocalJumpError', RubyStandardError);
var RubyTypeError     = define_class(rb_cObject, 'TypeError', RubyStandardError);
var RubyNameError     = define_class(rb_cObject, 'NameError', RubyStandardError);
var RubyNoMethodError = define_class(rb_cObject, 'NoMethodError', RubyNameError);
var RubyArgError      = define_class(rb_cObject, 'ArgumentError', RubyStandardError);
var RubyScriptError   = define_class(rb_cObject, 'ScriptError', RubyException);
var RubyLoadError     = define_class(rb_cObject, 'LoadError', RubyScriptError);
var RubyIndexError    = define_class(rb_cObject, 'IndexError', RubyStandardError);
var RubyKeyError      = define_class(rb_cObject, 'KeyError', RubyIndexError);
var RubyRangeError    = define_class(rb_cObject, 'RangeError', RubyStandardError);
var RubyNotImplError  = define_class(rb_cObject, 'NotImplementedError', RubyException);

RubyException.$a.prototype.toString = function() {
  return this.$k.__classid__ + ': ' + this.message;
};

var RubyBreakInstance = new Error('unexpected break');
RubyBreakInstance.$k = RubyLocalJumpError;
RubyBreakInstance.$t = function() { throw this; };
VM.B = RubyBreakInstance;
var breaker = RubyBreakInstance;
