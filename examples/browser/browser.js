opal.register('browser.js', function($runtime, self, __FILE__) { $$init();
self.$m.$puts(self, "Hello, world! Running in the browser..");


"All code is generated to keep the same line as the original ruby";
self.$m.$puts(self, ("This code is generated from line " + (__b = 6).$m.to_s(__b) + ", in file: " + (__b = __FILE__).$m.to_s(__b)));


title = document.title;
self.$m.$puts(self, ("The document title is '" + (__b = title).$m.to_s(__b) + "'"));


(($B.p = function(self, a) {var $A = arguments, $L = $A.length; var __a;if (a === undefined) { a = nil; }
  return self.$m.$puts(self, a);
}).$proc = [self], $B.f = (__a = [1, 2, 3, 4, 5]).$m.each)(__a);


$class(self, nil, 'ClassA', function(self) {
  return $def(self, 'method_missing', function(self, method_id, args) { var __a, __b, __c;var $A = arguments, $M = $A.callee, $L = $A.length;if ($L < 2) { $ac(1, $L - 1); }args = [].slice.call($A, 2);
    return self.$m.$puts(self, ("Tried to call '" + (__b = method_id).$m.to_s(__b) + "' with: " + (__b = args.$m.inspect(args)).$m.to_s(__b)));
  }, 0);
}, 0);

self['@cls'] = (__a = rb_vm_cg(self, 'ClassA')).$m['new'](__a);
(__a = self['@cls']).$m.try_this(__a);
(__a = self['@cls']).$m['do_assign='](__a, "this won't work");
(__a = self['@cls']).$m['[]='](__a, 'neither', $symbol('will_this'));
(__a = self['@cls']).$m['is_this_true?'](__a);
(__a = self['@cls']).$m['no_its_not!'](__a);
(__a = self['@cls']).$m['+'](__a, 'something to add');


self.$m.$puts(self, (__b = 1).$m['+'](__b, 2));
self.$m.$puts(self, (__b = [1, 2, 3, 4]).$m['[]'](__b, 0));
self.$m.$puts(self, (__b = [1, 2, 3, 4]).$m['[]'](__b, -2));


$class(self, rb_vm_cg(self, 'Exception'), 'CustomBrowserException', function(self) {  return nil;}, 0);

try {
  self.$m.$raise(self, rb_vm_cg(self, 'CustomBrowserException'), "some error happened");} catch (__err__) {
  if (true){e = __err__;
    self.$m.$puts(self, "caught error:");
    self.$m.$puts(self, e.$m.inspect(e));}
};

var nil, $ac, $super, $break, $class, $def, $symbol, $range, $hash, $B, Qtrue, Qfalse;var __a, __b, title, e;
function $$init() {nil = $runtime.Qnil, $ac = $runtime.ac, $super = $runtime.S, $break = $runtime.B, $class = $runtime.dc, $def = $runtime.dm, $symbol = $runtime.Y, $range = $runtime.G, $hash = $runtime.H, $B = $runtime.P, Qtrue = $runtime.Qtrue, Qfalse = $runtime.Qfalse;$runtime.mm(['puts', 'to_s', 'each', 'inspect', 'new', 'try_this', 'do_assign=', '[]=', 'is_this_true?', 'no_its_not!', '+', '[]', 'raise']);if (self['@cls'] == undefined) { self['@cls'] = nil; }}
 });
opal.require('browser');
