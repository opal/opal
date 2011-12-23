// Initialization
// --------------

// The *instances* of core objects
var BootObject = boot_defclass();
var BootModule = boot_defclass(BootObject);
var BootClass  = boot_defclass(BootModule);

// The *classes' of core objects
var RubyObject = boot_makemeta('Object', BootObject, BootClass);
var RubyModule = boot_makemeta('Module', BootModule, RubyObject.constructor);
var RubyClass = boot_makemeta('Class', BootClass, RubyModule.constructor);

// Fix boot classes to use meta class
RubyObject.$k = RubyClass;
RubyModule.$k = RubyClass;
RubyClass.$k = RubyClass;

// fix superclasses
RubyObject.$s = null;
RubyModule.$s = RubyObject;
RubyClass.$s = RubyModule;

RubyObject.$c.BasicObject = RubyObject;
RubyObject.$c.Object = RubyObject;
RubyObject.$c.Module = RubyModule;
RubyObject.$c.Class = RubyClass;

opal.Object = RubyObject;

var top_self = opal.top = new RubyObject.$a();

var RubyNilClass  = define_class(RubyObject, 'NilClass', RubyObject);
var nil = opal.nil = new RubyNilClass.$a();

var RubyArray     = bridge_class(Array, T_OBJECT | T_ARRAY, 'Array');
var RubyNumeric   = bridge_class(Number, T_OBJECT | T_NUMBER, 'Numeric');

var RubyHash      = define_class(RubyObject, 'Hash', RubyObject);

var RubyString    = bridge_class(String, T_OBJECT | T_STRING, 'String');
var RubyBoolean   = bridge_class(Boolean, T_OBJECT | T_BOOLEAN, 'Boolean');
var RubyProc      = bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
var RubyRegexp    = bridge_class(RegExp, T_OBJECT, 'Regexp');

var RubyMatch     = define_class(RubyObject, 'MatchData', RubyObject);
var RubyRange     = define_class(RubyObject, 'Range', RubyObject);

var RubyException      = bridge_class(Error, T_OBJECT, 'Exception');
var RubyStandardError  = define_class(RubyObject, 'StandardError', RubyException);
var RubyRuntimeError   = define_class(RubyObject, 'RuntimeError', RubyException);
var RubyLocalJumpError = define_class(RubyObject, 'LocalJumpError', RubyStandardError);
var RubyTypeError      = define_class(RubyObject, 'TypeError', RubyStandardError);
var RubyNameError      = define_class(RubyObject, 'NameError', RubyStandardError);
var RubyNoMethodError  = define_class(RubyObject, 'NoMethodError', RubyNameError);
var RubyArgError       = define_class(RubyObject, 'ArgumentError', RubyStandardError);
var RubyScriptError    = define_class(RubyObject, 'ScriptError', RubyException);
var RubyLoadError      = define_class(RubyObject, 'LoadError', RubyScriptError);
var RubyIndexError     = define_class(RubyObject, 'IndexError', RubyStandardError);
var RubyKeyError       = define_class(RubyObject, 'KeyError', RubyIndexError);
var RubyRangeError     = define_class(RubyObject, 'RangeError', RubyStandardError);
var RubyNotImplError   = define_class(RubyObject, 'NotImplementedError', RubyException);

RubyException.$a.prototype.toString = function() {
  return this.$k.__classid__ + ': ' + this.message;
};

var breaker = opal.breaker  = new Error('unexpected break');
    breaker.$k              = RubyLocalJumpError;
    breaker.$t              = function() { throw this; };
