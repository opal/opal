opal.register('rquery_demo.js', function($runtime, self, __FILE__) { var nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, $class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $hash = $runtime.H, $block = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;$runtime.mm(['require', 'ready?', 'include', 'click', '[]', 'alert', 'add_class', 'find', 'each', 'puts', 'html']);var __a, __b, __c;
(__a = self).$m.$require(__a, 'rquery');


(__a = $runtime.gg('$document'), __b = [__a], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length;  return nil;

}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));


(__b = self).$m.$include(__b, rb_vm_cg(self, 'RQuery'));


(__b = rb_vm_cg(self, 'Document'), __a = [__b], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length;  return nil;

}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a));


(__a = $runtime.gg('$document'), __b = [__a], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a, __b, __c;
  return (__a = (__b = $runtime.gg('$document')).$m['[]'](__b, 'a'), __b = [__a], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a;    return (__a = self).$m.$alert(__a, "Hello world!");}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m.click).apply(__a, __b));
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));


(__b = $runtime.gg('$document'), __a = [__b], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a, __b, __c, __d;
  return (__a = (__b = (__c = (__d = $runtime.gg('$document')).$m['[]'](__d, '#orderedlist')).$m.add_class(__c, 'red')).$m.find(__b, 'li')).$m.add_class(__a, 'blue');
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a));


(__a = $runtime.gg('$document'), __b = [__a], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a, __b, __c;
  return (__a = (__b = $runtime.gg('$document')).$m['[]'](__b, 'li'), __b = [__a], ($block.p = (__c = function(self, elem) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a, __b;if (elem === undefined) { elem = nil; }    return (__a = self).$m.$puts(__a, (__b = elem).$m.html(__b));}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m.each).apply(__a, __b));
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m['ready?']).apply(__a, __b));

(__b = $runtime.gg('$document'), __a = [__b], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a, __b, __c;
  return (__a = $runtime.gg('$document'), __b = [__a], ($block.p = (__c = function(self) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a;
    return (__a = self).$m.$puts(__a, "clicked doc!");
  }, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m.click).apply(__a, __b));
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __b.$m['ready?']).apply(__b, __a));
 });
opal.require('rquery_demo');
