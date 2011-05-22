opal.register('browser.js', function($runtime, self, __FILE__) { var nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, $class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $range = $runtime.G, $hash = $runtime.H, $block = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;$runtime.mm(['puts', 'to_s', 'each', 'inspect', 'new', 'try_this', 'do_assign=', '[]=', 'is_this_true?', 'no_its_not!', '+', '[]', 'raise']);var __a, __b, title, __c, e;if (self['@cls'] == undefined) { self['@cls'] = nil; }
self.$m.$puts(self, "Hello, world! Running in the browser..");


"All code is generated to keep the same line as the original ruby";
self.$m.$puts(self, ("This code is generated from line " + (__b = 6).$m.to_s(__b) + ", in file: " + (__b = __FILE__).$m.to_s(__b)));


title = document.title;
self.$m.$puts(self, ("The document title is '" + (__b = title).$m.to_s(__b) + "'"));


(__a = [1, 2, 3, 4, 5], __b = [__a], ($block.p = (__c = function(self, a) {var $args = arguments, $meth = $args.callee, $len = $args.length; var __a;if (a === undefined) { a = nil; }
  return self.$m.$puts(self, a);
}, __c.$arity = 0, __c.$meth = null, __c)).$self = self, ($block.f = __a.$m.each).apply(__a, __b));


$class(self, nil, 'ClassA', function(self) {
  return $def(self, 'method_missing', function(self, method_id, args) { var __a, __b, __c;var $args = arguments, $meth = $args.callee, $len = $args.length;if ($len < 2) { $ac(1, $len - 1); }args = [].slice.call($args, 2);
    return self.$m.$puts(self, ("Tried to call '" + (__b = method_id).$m.to_s(__b) + "' with: " + (__b = args.$m.inspect(args)).$m.to_s(__b)));
  }, 0);
}, 0);

self['@cls'] = (__b = rb_vm_cg(self, 'ClassA')).$m['new'](__b);
(__b = self['@cls']).$m.try_this(__b);
(__b = self['@cls']).$m['do_assign='](__b, "this won't work");
(__b = self['@cls']).$m['[]='](__b, 'neither', $symbol('will_this'));
(__b = self['@cls']).$m['is_this_true?'](__b);
(__b = self['@cls']).$m['no_its_not!'](__b);
(__b = self['@cls']).$m['+'](__b, 'something to add');


self.$m.$puts(self, (__a = 1).$m['+'](__a, 2));
self.$m.$puts(self, (__a = [1, 2, 3, 4]).$m['[]'](__a, 0));
self.$m.$puts(self, (__a = [1, 2, 3, 4]).$m['[]'](__a, -2));


$class(self, rb_vm_cg(self, 'Exception'), 'CustomBrowserException', function(self) {  return nil;}, 0);

try {
  self.$m.$raise(self, rb_vm_cg(self, 'CustomBrowserException'), "some error happened");} catch (__err__) {
  if (true){e = __err__;
    self.$m.$puts(self, "caught error:");
    self.$m.$puts(self, e.$m.inspect(e));}
};
 });
opal.require('browser');
