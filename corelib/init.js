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

init_module();

var rb_mKernel = define_module(rb_cObject, 'Kernel');

// core, non-bridged, classes
var rb_cMatch     = define_class(rb_cObject, 'MatchData', rb_cObject);
var rb_cRange     = define_class(rb_cObject, 'Range', rb_cObject);
var rb_cNilClass  = define_class(rb_cObject, 'NilClass', rb_cObject);

var rb_top_self = VM.top = new rb_cObject.$a();
init_nil();

// core bridged classes
init_enumerable();
init_array();
init_hash();
init_numeric();
init_string();
init_error();
init_boolean();
var rb_cProc      = rb_bridge_class(Function, T_OBJECT | T_PROC, 'Proc');
var rb_cRegexp    = rb_bridge_class(RegExp, T_OBJECT, 'Regexp');

// other core errors and exception classes
