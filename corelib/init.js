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

var rb_mKernel = define_module(rb_cObject, 'Kernel');

// core, non-bridged, classes
var rb_cMatch     = define_class(rb_cObject, 'MatchData', rb_cObject);
var rb_cRange     = define_class(rb_cObject, 'Range', rb_cObject);
var rb_cHash      = define_class(rb_cObject, 'Hash', rb_cObject);
var rb_cNilClass  = define_class(rb_cObject, 'NilClass', rb_cObject);

var rb_top_self = VM.top = new rb_cObject.$a();
var Qnil = VM.nil = new rb_cNilClass.$a();
var nil = Qnil;

// core bridged classes
var rb_cBoolean   = rb_bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
init_enumerable();
init_array();
init_numeric();
var rb_cString    = rb_bridge_class(String, T_OBJECT | T_STRING, 'String');
var rb_cProc      = rb_bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
var rb_cRegexp    = rb_bridge_class(RegExp, T_OBJECT, 'Regexp');
var rb_eException = rb_bridge_class(Error, T_OBJECT, 'Exception');

// other core errors and exception classes
var rb_eStandardError = define_class(rb_cObject, 'StandardError', rb_eException);
var rb_eRuntimeError  = define_class(rb_cObject, 'RuntimeError', rb_eException);
var rb_eLocalJumpError= define_class(rb_cObject, 'LocalJumpError', rb_eStandardError);
var rb_eTypeError     = define_class(rb_cObject, 'TypeError', rb_eStandardError);
var rb_eNameError     = define_class(rb_cObject, 'NameError', rb_eStandardError);
var rb_eNoMethodError = define_class(rb_cObject, 'NoMethodError', rb_eNameError);
var rb_eArgError      = define_class(rb_cObject, 'ArgumentError', rb_eStandardError);
var rb_eScriptError   = define_class(rb_cObject, 'ScriptError', rb_eException);
var rb_eLoadError     = define_class(rb_cObject, 'LoadError', rb_eScriptError);
var rb_eIndexError    = define_class(rb_cObject, 'IndexError', rb_eStandardError);
var rb_eKeyError      = define_class(rb_cObject, 'KeyError', rb_eIndexError);
var rb_eRangeError    = define_class(rb_cObject, 'RangeError', rb_eStandardError);
var rb_eNotImplError  = define_class(rb_cObject, 'NotImplementedError', rb_eException);

var rb_eBreakInstance = new Error('unexpected break');
rb_eBreakInstance.$k = rb_eLocalJumpError;
rb_eBreakInstance.$t = function() { throw this; };
VM.B = rb_eBreakInstance;
var breaker = rb_eBreakInstance;
